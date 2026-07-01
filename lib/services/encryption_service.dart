import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  static const int _keyLength = 32;
  static const int _ivLength = 16;

  // ─── 安全存储 key ───────────────────────────
  static const _secureStorage = FlutterSecureStorage();
  static const _kPasswordKey = 'enc_password_v2';
  static const _kSaltKey = 'enc_salt_v2';

  /// 旧版硬编码密钥（仅用于解密迁移，不再用于加密新数据）
  static const _legacyPassword = 'sWJ92kLpXzMnQbVrT7yH3gDfSaWeRtYuIoP';
  static const _legacySalt = 'sh1wUj1_A1_C0nf1g_S4lt';

  /// 缓存的当前密钥（init 后填充，避免每次加密都读安全存储）
  Uint8List? _cachedKey;

  /// 缓存的旧版密钥（惰性计算，用于迁移回退）
  Uint8List? _cachedLegacyKey;

  /// 初始化 —— 在 App 启动时调用一次。
  ///
  /// 从安全存储加载密钥；首次安装时生成随机密钥并写入。
  Future<void> init() async {
    _cachedKey = await _loadOrGenerateKey();
  }

  /// 从安全存储加载密钥，不存在则生成随机密钥并存储。
  Future<Uint8List> _loadOrGenerateKey() async {
    final storedPassword = await _secureStorage.read(key: _kPasswordKey);
    final storedSalt = await _secureStorage.read(key: _kSaltKey);

    if (storedPassword != null && storedSalt != null) {
      return _pbkdf2(
        utf8.encode(storedPassword),
        utf8.encode(storedSalt),
        10000,
        _keyLength,
      );
    }

    // 首次使用：生成随机 password 和 salt
    final random = Random.secure();
    final newPassword = _generateRandomBase64(32, random);
    final newSalt = _generateRandomBase64(16, random);

    await _secureStorage.write(key: _kPasswordKey, value: newPassword);
    await _secureStorage.write(key: _kSaltKey, value: newSalt);

    return _pbkdf2(
      utf8.encode(newPassword),
      utf8.encode(newSalt),
      10000,
      _keyLength,
    );
  }

  String _generateRandomBase64(int byteLength, Random random) {
    final bytes = Uint8List.fromList(
      List<int>.generate(byteLength, (_) => random.nextInt(256)),
    );
    return base64.encode(bytes);
  }

  /// 获取旧版密钥（惰性缓存）
  Uint8List get _legacyKey {
    return _cachedLegacyKey ??= _pbkdf2(
      utf8.encode(_legacyPassword),
      utf8.encode(_legacySalt),
      10000,
      _keyLength,
    );
  }

  /// 获取当前密钥（必须已调用 init）
  Uint8List get _currentKey {
    final key = _cachedKey;
    if (key == null) {
      throw StateError(
        'EncryptionService 未初始化，请在 App 启动时调用 init()',
      );
    }
    return key;
  }

  Uint8List _pbkdf2(
    Uint8List password,
    Uint8List salt,
    int iterations,
    int derivedKeyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final blocks = (derivedKeyLength / 32).ceil();
    final derivedKey = BytesBuilder();

    for (var i = 1; i <= blocks; i++) {
      var u = Uint8List.fromList([
        ...salt,
        (i >> 24) & 0xff,
        (i >> 16) & 0xff,
        (i >> 8) & 0xff,
        i & 0xff,
      ]);
      u = Uint8List.fromList(hmac.convert(u).bytes);
      final result = Uint8List.fromList(u);

      for (var j = 1; j < iterations; j++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < result.length; k++) {
          result[k] ^= u[k];
        }
      }
      derivedKey.add(result);
    }

    return derivedKey.takeBytes().sublist(0, derivedKeyLength);
  }

  String encrypt(String plaintext) {
    if (plaintext.isEmpty) return '';

    final key = _currentKey;
    final iv = _generateRandomBytes(_ivLength);
    final plainBytes = utf8.encode(plaintext);

    final encrypted = _aesCbcEncrypt(key, iv, _pad(plainBytes, _ivLength));
    final combined = BytesBuilder()
      ..add(iv)
      ..add(encrypted);

    return base64.encode(combined.takeBytes());
  }

  /// 使用当前密钥解密。解密失败时自动回退到旧版硬编码密钥（迁移兼容）。
  ///
  /// 返回值:
  /// - 正常解密：返回明文
  /// - 旧版密钥解密成功：返回明文（调用方应使用 [needsReEncryption] 检查是否需要重新加密）
  /// - 都失败：返回空字符串
  bool _lastDecryptUsedLegacy = false;

  String decrypt(String ciphertext) {
    if (ciphertext.isEmpty) return '';
    _lastDecryptUsedLegacy = false;

    // 先尝试当前密钥
    final result = _decryptWithKey(_currentKey, ciphertext);
    if (result != null) return result;

    // 回退到旧版密钥
    final legacyResult = _decryptWithKey(_legacyKey, ciphertext);
    if (legacyResult != null) {
      _lastDecryptUsedLegacy = true;
      return legacyResult;
    }

    return '';
  }

  /// 上次 decrypt 是否使用了旧版密钥回退。
  ///
  /// 为 true 时，调用方应重新加密并保存，以完成密钥迁移。
  bool get needsReEncryption => _lastDecryptUsedLegacy;

  /// 用指定密钥解密，失败返回 null。
  String? _decryptWithKey(Uint8List key, String ciphertext) {
    try {
      final combined = base64.decode(ciphertext);
      if (combined.length <= _ivLength) return null;

      final iv = combined.sublist(0, _ivLength);
      final encrypted = combined.sublist(_ivLength);
      final decrypted = _aesCbcDecrypt(key, iv, encrypted);
      final unpadded = _unpad(decrypted);

      return utf8.decode(unpadded);
    } catch (_) {
      return null;
    }
  }

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List _pad(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = BytesBuilder()..add(data);
    for (var i = 0; i < padLength; i++) {
      padded.addByte(padLength);
    }
    return padded.takeBytes();
  }

  Uint8List _unpad(Uint8List data) {
    final padLength = data.last;
    if (padLength <= 0 || padLength > _ivLength) return data;
    for (var i = data.length - padLength; i < data.length; i++) {
      if (data[i] != padLength) return data;
    }
    return data.sublist(0, data.length - padLength);
  }

  Uint8List _aesCbcEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    final cipher = _AesCipher(key);
    final ciphertext = BytesBuilder();
    var previousBlock = iv;

    for (var i = 0; i < plaintext.length; i += _ivLength) {
      final block = plaintext.sublist(i, i + _ivLength);
      final xoredBlock = _xorBlocks(block, previousBlock);
      final encryptedBlock = cipher.encryptBlock(xoredBlock);
      ciphertext.add(encryptedBlock);
      previousBlock = encryptedBlock;
    }

    return ciphertext.takeBytes();
  }

  Uint8List _aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List ciphertext) {
    final cipher = _AesCipher(key);
    final plaintext = BytesBuilder();
    var previousBlock = iv;

    for (var i = 0; i < ciphertext.length; i += _ivLength) {
      final block = ciphertext.sublist(i, i + _ivLength);
      final decryptedBlock = cipher.decryptBlock(block);
      final xoredBlock = _xorBlocks(decryptedBlock, previousBlock);
      plaintext.add(xoredBlock);
      previousBlock = block;
    }

    return plaintext.takeBytes();
  }

  Uint8List _xorBlocks(Uint8List a, Uint8List b) {
    final result = Uint8List(a.length);
    for (var i = 0; i < a.length; i++) {
      result[i] = a[i] ^ b[i];
    }
    return result;
  }
}

class _AesCipher {
  final List<int> _roundKeys;
  final int _rounds;
  static const _sBox = <int>[
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16,
  ];
  static const _invSBox = <int>[
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d,
  ];
  static const _rcon = <int>[
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36,
  ];

  _AesCipher(Uint8List key)
      : _rounds = key.length == 32 ? 14 : (key.length == 24 ? 12 : 10),
        _roundKeys = _expandKey(key);

  static List<int> _expandKey(Uint8List key) {
    final expanded = List<int>.filled(240, 0);
    final keyLength = key.length;
    for (var i = 0; i < keyLength; i++) {
      expanded[i] = key[i];
    }

    var bytesGenerated = keyLength;
    var rconIndex = 1;

    while (bytesGenerated < 240) {
      var temp = expanded.sublist(bytesGenerated - 4, bytesGenerated);
      if (bytesGenerated % keyLength == 0) {
        temp = _subWord(_rotateWord(temp));
        temp[0] ^= _rcon[rconIndex++];
      } else if (keyLength > 24 && bytesGenerated % keyLength == 16) {
        temp = _subWord(temp);
      }
      for (var i = 0; i < 4; i++) {
        expanded[bytesGenerated] = expanded[bytesGenerated - keyLength] ^ temp[i];
        bytesGenerated++;
      }
    }
    return expanded;
  }

  static List<int> _subWord(List<int> word) {
    return [_sBox[word[0]], _sBox[word[1]], _sBox[word[2]], _sBox[word[3]]];
  }

  static List<int> _rotateWord(List<int> word) {
    return [word[1], word[2], word[3], word[0]];
  }

  Uint8List encryptBlock(Uint8List block) {
    var state = _blockToState(block);
    _addRoundKey(state, _roundKeys, 0);

    for (var round = 1; round < _rounds; round++) {
      _subBytes(state);
      _shiftRows(state);
      _mixColumns(state);
      _addRoundKey(state, _roundKeys, round * 16);
    }

    _subBytes(state);
    _shiftRows(state);
    _addRoundKey(state, _roundKeys, _rounds * 16);

    return _stateToBlock(state);
  }

  Uint8List decryptBlock(Uint8List block) {
    var state = _blockToState(block);
    _addRoundKey(state, _roundKeys, _rounds * 16);

    for (var round = _rounds - 1; round >= 1; round--) {
      _invShiftRows(state);
      _invSubBytes(state);
      _addRoundKey(state, _roundKeys, round * 16);
      _invMixColumns(state);
    }

    _invShiftRows(state);
    _invSubBytes(state);
    _addRoundKey(state, _roundKeys, 0);

    return _stateToBlock(state);
  }

  List<List<int>> _blockToState(Uint8List block) {
    return List.generate(4, (c) => List.generate(4, (r) => block[r * 4 + c]));
  }

  Uint8List _stateToBlock(List<List<int>> state) {
    final block = Uint8List(16);
    for (var c = 0; c < 4; c++) {
      for (var r = 0; r < 4; r++) {
        block[r * 4 + c] = state[c][r];
      }
    }
    return block;
  }

  void _addRoundKey(List<List<int>> state, List<int> roundKeys, int offset) {
    for (var c = 0; c < 4; c++) {
      for (var r = 0; r < 4; r++) {
        state[c][r] ^= roundKeys[offset + c * 4 + r];
      }
    }
  }

  void _subBytes(List<List<int>> state) {
    for (var c = 0; c < 4; c++) {
      for (var r = 0; r < 4; r++) {
        state[c][r] = _sBox[state[c][r]];
      }
    }
  }

  void _invSubBytes(List<List<int>> state) {
    for (var c = 0; c < 4; c++) {
      for (var r = 0; r < 4; r++) {
        state[c][r] = _invSBox[state[c][r]];
      }
    }
  }

  void _shiftRows(List<List<int>> state) {
    for (var r = 1; r < 4; r++) {
      final temp = List<int>.from(state.map((col) => col[r]));
      for (var c = 0; c < 4; c++) {
        state[c][r] = temp[(c + r) % 4];
      }
    }
  }

  void _invShiftRows(List<List<int>> state) {
    for (var r = 1; r < 4; r++) {
      final temp = List<int>.from(state.map((col) => col[r]));
      for (var c = 0; c < 4; c++) {
        state[c][r] = temp[(c + 4 - r) % 4];
      }
    }
  }

  void _mixColumns(List<List<int>> state) {
    for (var c = 0; c < 4; c++) {
      final a = List<int>.from(state[c]);
      state[c][0] = _gmul(2, a[0]) ^ _gmul(3, a[1]) ^ a[2] ^ a[3];
      state[c][1] = a[0] ^ _gmul(2, a[1]) ^ _gmul(3, a[2]) ^ a[3];
      state[c][2] = a[0] ^ a[1] ^ _gmul(2, a[2]) ^ _gmul(3, a[3]);
      state[c][3] = _gmul(3, a[0]) ^ a[1] ^ a[2] ^ _gmul(2, a[3]);
    }
  }

  void _invMixColumns(List<List<int>> state) {
    for (var c = 0; c < 4; c++) {
      final a = List<int>.from(state[c]);
      state[c][0] = _gmul(0x0e, a[0]) ^ _gmul(0x0b, a[1]) ^ _gmul(0x0d, a[2]) ^ _gmul(0x09, a[3]);
      state[c][1] = _gmul(0x09, a[0]) ^ _gmul(0x0e, a[1]) ^ _gmul(0x0b, a[2]) ^ _gmul(0x0d, a[3]);
      state[c][2] = _gmul(0x0d, a[0]) ^ _gmul(0x09, a[1]) ^ _gmul(0x0e, a[2]) ^ _gmul(0x0b, a[3]);
      state[c][3] = _gmul(0x0b, a[0]) ^ _gmul(0x0d, a[1]) ^ _gmul(0x09, a[2]) ^ _gmul(0x0e, a[3]);
    }
  }

  int _gmul(int a, int b) {
    var p = 0;
    for (var i = 0; i < 8; i++) {
      if ((b & 1) != 0) p ^= a;
      final hi = (a & 0x80) != 0;
      a = (a << 1) & 0xff;
      if (hi) a ^= 0x1b;
      b >>= 1;
    }
    return p;
  }
}
