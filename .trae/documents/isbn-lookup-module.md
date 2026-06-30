# ISBN 图书信息查询模块实现计划

## Context（背景）

项目「拾物记」(ShiWuJi) 已有「书籍」品类模板（含作者/出版社/ISBN/版本字段，见 `lib/models/template.dart:83`），但缺少通过 ISBN 自动获取图书详细信息的能力。本次需创建一个独立的 ISBN 解析与图书信息查询功能模块，参照 GitHub 项目 [DoiiarX/NLCISBNPlugin](https://github.com/DoiiarX/NLCISBNPlugin)（Python 实现，查询中国国家图书馆 OPAC）移植为 Dart/Flutter 模块。

**用户决策**：
- CLC（中图分类号）数据采用**精简数据集**（22 个大类 + 二级子类，约 300 条），解析器数据驱动，文档说明可随时替换为完整 8MB 数据树。
- 实现范围**仅功能模块 + 文档 + 单元测试**，不改动现有 UI、不接入「添加物品」书籍流程。

**预期产出**：可独立调用的 `IsbnService`，输入 ISBN 字符串，输出结构化 `BookInfo`（书名、作者、出版社、出版日期、ISBN、简介、主题、中图分类号及名称）；含内存 LRU+TTL 缓存、完善的类型化错误处理、使用示例、API 文档、单元测试。

---

## 架构与文件结构

遵循项目既有约定：单例服务（`Service._()` + `static final instance`，见 `lib/services/update_service.dart`、`lib/services/photo_service.dart`）；HTTP 走 `HttpService.instance.getRaw`（见 `lib/services/http_service.dart`）；freezed 模型放 `lib/models/`（**关键约束**：`build.yaml` 仅对 `lib/models/`、`lib/providers/`、`lib/database/`、`lib/daos/` 配置了 `build_extensions`，放别处会导致 `build_runner` 生成路径错误）。

```
lib/models/
  book_info.dart                    新增 (freezed) — 查询结果数据模型
  clc_info.dart                     新增 (freezed) — ClcClass 树节点 + ClcInfo 查询结果
  generated/
    book_info.freezed.dart          (codegen)
    book_info.g.dart                (codegen)
    clc_info.freezed.dart           (codegen)
    clc_info.g.dart                 (codegen)

lib/services/isbn/
  isbn_exception.dart               新增 — IsbnErrorCode 枚举 + IsbnException
  isbn_validator.dart               新增 — 纯函数：ISBN 校验/转换（无 I/O）
  nlc_html_parser.dart              新增 — 纯函数：<table id="td"> → Map<String,String>
  nlc_field_extractor.dart          新增 — 纯函数：Map + 原始 HTML → 各字段
  clc_parser.dart                   新增 — 纯函数：原始 CLC 串 + 树 → 分级 codes
  clc_dataset.dart                  新增 — 懒加载单例：rootBundle 加载 JSON 树，构建扁平查找表
  isbn_cache.dart                   新增 — 内存 LRU + TTL 缓存
  isbn_service.dart                 新增 — IsbnService 单例（对外 API）

test/models/
  book_info_test.dart               新增
  clc_info_test.dart                新增
test/services/isbn/
  isbn_validator_test.dart          新增
  clc_parser_test.dart              新增
  nlc_html_parser_test.dart         新增
  nlc_field_extractor_test.dart     新增
  clc_dataset_test.dart             新增
  isbn_cache_test.dart              新增
  isbn_service_test.dart            新增
  fixtures/
    nlc_detail_9787111544937.html   新增 — 代表性 NLC 详情页 HTML

assets/isbn/
  clc_compact.json                  新增 — 精简 CLC 分类树（22 大类 + 二级子类）

docs/isbn/
  README.md                         新增 — 概览 + 使用示例
  api.md                            新增 — 逐符号 API 参考
  nlc_protocol.md                   新增 — NLC 协议/请求头/编码说明
  clc_dataset.md                    新增 — JSON schema + 如何替换完整数据树
```

需修改：`pubspec.yaml`（加 `html` 依赖 + `assets/isbn/` 资源目录）。

---

## 数据模型（freezed，位于 `lib/models/`）

### `BookInfo`（`lib/models/book_info.dart`）
```dart
@freezed
abstract class BookInfo with _$BookInfo {
  const factory BookInfo({
    required String isbn13,            // 规范化的 13 位 ISBN
    required String title,             // 题名与责任（缺失时回退为 isbn13）
    @Default([]) List<String> authors, // 著者，按 \n 拆分，可去除"著/编"后缀
    @Default('') String publisher,     // 出版项 → ":<出版社>," group 1
    @Default('') String pubDate,       // 仅年份（通用数据 → 出版项 回退）
    @Default('') String synopsis,      // 内容提要 原文
    @Default([]) List<String> subjects,// 主题，"--"→分隔
    @Default('') String clcCode,       // 中图分类号 原始串
    String? clcCategory,               // 解析出的二级分类名称（可空）
    @Default('') String sourceUrl,     // NLC 详情页 URL（溯源）
    @Default({}) Map<String, String> rawFields, // 完整解析表（调试用）
  }) = _BookInfo;
  factory BookInfo.fromJson(Map<String, dynamic> json) => _$BookInfoFromJson(json);
}
```

### `ClcClass` / `ClcInfo`（`lib/models/clc_info.dart`）
```dart
@freezed
abstract class ClcClass with _$ClcClass {
  const factory ClcClass({
    required String code,
    required String name,
    @Default([]) List<ClcClass> children, // 递归，freezed 3.x 支持
  }) = _ClcClass;
  factory ClcClass.fromJson(Map<String, dynamic> json) => _$ClcClassFromJson(json);
}

@freezed
abstract class ClcInfo with _$ClcInfo {
  const factory ClcInfo({
    required String code,
    required String name,
    required List<String> path,       // ['T', 'TP']
    required List<String> namePath,   // ['工业技术', '自动化技术、计算机技术']
  }) = _ClcInfo;
  factory ClcInfo.fromJson(Map<String, dynamic> json) => _$ClcInfoFromJson(json);
}
```

---

## 关键模块与签名

### `isbn_exception.dart`
```dart
enum IsbnErrorCode { invalidFormat, sessionError, notFound, network, parseError, unknown }

class IsbnException implements Exception {
  final IsbnErrorCode code;
  final String message;
  final String? isbn;
  final Object? cause;
  const IsbnException(this.code, this.message, {this.isbn, this.cause});
  @override
  String toString() => 'IsbnException($code): $message${isbn != null ? ' (isbn=$isbn)' : ''}';
}
```

### `isbn_validator.dart`（纯函数，精确移植 Python 参考实现）
```dart
class IsbnValidator {
  IsbnValidator._();
  static String canonical(String s);     // 仅保留 0-9Xx，末尾 x→X；拒绝长度非 10/13、全 0、X 不在末位
  static String checkDigit10(String first9);  // 权重 10..2，mod 11，10→'X'
  static String checkDigit13(String first12); // 权重 1,3 交替，mod 10
  static bool isIsbn10(String s);
  static bool isIsbn13(String s);         // 前缀须为 978 或 979
  static String toIsbn13(String s);       // 10 位→13 位（978 前缀）；非法返回 ''
}
```
实现要点（须精确）：
- `checkDigit10`：`s = Σ (10-i)*int(first9[i]) for i in 0..8; r = s % 11; r==0?'0': r==10?'X': (11-r).toString()`
- `checkDigit13`：`s = Σ (i 偶?1:3)*int(first12[i]); ((10 - s%10) % 10).toString()`
- `canonical`：正则 `[^0-9Xx]` 去除；末尾 `x`→`X`；拒绝集 `{0000000000, 0000000000000, 000000000X}`；10 位形式要求 `X` 只在 index 9。

### `nlc_html_parser.dart`（纯函数）
```dart
class NlcHtmlParser {
  NlcHtmlParser._();
  static bool hasDetailTable(String html);              // 是否含 <table id="td">
  static Map<String, String> parseDetailTable(String html); // 解析为 label→value 映射
}
```
逻辑：用 `package:html/parser.dart` 的 `parse(html)` → `querySelector('table#td')` → 遍历 `querySelectorAll('tr')`；每行取两个 `td.td1`，文本 `replaceAll('\xa0', ' ')` 后 trim。首格为空 → 将次格值以 `\n` 追加到上一个 label。无表返回 `{}`。

### `nlc_field_extractor.dart`（纯函数）
```dart
class NlcFieldExtractor {
  NlcFieldExtractor._();
  static String title(Map<String,String> f, {required String fallbackIsbn13, bool stripSquareSuffix = false});
  static List<String> authors(Map<String,String> f, {bool stripRoleSuffix = false});
  static String publisher(Map<String,String> f);
  static String pubDate(Map<String,String> f);
  static String isbn13FromPageText(String rawHtml);
  static String synopsis(Map<String,String> f);
  static List<String> subjects(Map<String,String> f);
  static String clcCode(Map<String,String> f);
}
```
正则（精确移植）：
- 标题去后缀：`([\u4e00-\u9fa5a-zA-Z0-9]+(?:[\u4e00-\u9fa5a-zA-Z0-9\s]+)?)(?=\s\[[\u4e00-\u9fa5]{2}\])`
- 出版社：`:\s*(.+),\s`（取 group 1）
- 出版年（主）：`\d{9}(\d{4})`（通用数据第 10-13 位字符为年份）
- 出版年（回退）：`\b(\d{4})\b`（出版项）
- 页内 ISBN：`ISBN: ([\d\-]+)`（去连字符，10→13）
- 作者去角色：`^(.*?)\s+(?:著|编)`
- 主题：取 `主题` 值，`--` 替换为分隔符后拆分（见 pitfalls）

### `clc_parser.dart`（纯函数，**树驱动 + 最长前缀匹配**）
```dart
class ClcParsedCode {
  final String raw;
  final String? level1;
  final String? level2;
  final String? level3;
  const ClcParsedCode({required this.raw, this.level1, this.level2, this.level3});
  bool get isEmpty => level1 == null;
}

class ClcParser {
  ClcParser._();
  // 大类正则（A-K, N-V, X, Z；L/M/W/Y 排除）
  static final RegExp _majorRe = RegExp(r'(?:[A-K]|[N-V]|X|Z)[A-Z]?\d{0,3}');

  /// 按 ; 或 ；（全角）拆分；每段用 _majorRe 提取首个匹配（清洗括号等）；
  /// 对每个清洗后的 code 走树的最长前缀匹配分级。
  /// tree 来自 ClcDataset，作为参数注入以保持纯函数可测。
  static List<ClcParsedCode> parse(String raw, List<ClcClass> tree);
}
```
分级算法（最长前缀匹配，**修正参考实现的 regex 树法，更简洁且正确**）：
1. 清洗：对每段 `seg`，`_majorRe.stringMatch(seg)` 得到如 `TP311`。
2. level1：树顶层节点中 `cleanCode.startsWith(node.code)`，单字符匹配（如 `T`）。
3. level2：level1 的 children 中，找 `cleanCode.startsWith(child.code)` 且 `child.code` 最长者（如 `TP`，排除误匹配 `TB`）。
4. level3：level2 的 children 中同理（精简数据集无三级，跳过）。

**关键修正**：参考实现的大类正则 `(?:[A-K]|[N-V]|X|Z)` 中 `[N-V]` **包含 T**（N,O,P,Q,R,S,T,U,V）。因此 `TP311` 合法，level1=`T`，level2=`TP`（自动化技术、计算机技术）。仅 L、M、W、Y 被排除。

### `clc_dataset.dart`（懒加载单例，参照 `lib/services/prompt_service.dart` 的 rootBundle 模式）
```dart
class ClcDataset {
  ClcDataset._();
  static final ClcDataset instance = ClcDataset._();
  static const String assetPath = 'assets/isbn/clc_compact.json';

  List<ClcClass>? _tree;
  Map<String, ClcInfo>? _flat;     // code → ClcInfo（所有层级）
  Future<void>? _loadingFuture;

  Future<void> ensureLoaded();      // 幂等，缓存 Future
  Future<void> reload();            // 重读资源（热替换/测试）
  Future<ClcInfo?> getClcInfoByCode(String code);
  Future<ClcInfo?> resolveCategory(String rawClc); // parse → 取 level2（回退 level1）→ 查找

  @visibleForTesting
  void setDatasetForTesting(List<ClcClass> tree);
  @visibleForTesting
  void resetForTesting();
}
```
扁平表构建：遍历树，根节点存 `ClcInfo(code,name,[code],[name])`；每个 child 存 `ClcInfo(child.code, child.name, [root.code, child.code], [root.name, child.name])`。三级同理递归。

`resolveCategory`：`ClcParser.parse(raw, tree)` → 取首个非空 ParsedCode 的 `level2 ?? level1` → `getClcInfoByCode`；消费者读 `info.namePath[1]`（若 path 长度 < 2 用 `info.name`）。

### `isbn_cache.dart`（内存 LRU + TTL）
```dart
class IsbnCache {
  IsbnCache({this.maxSize = 100, this.ttl = const Duration(days: 7), DateTime Function()? now});
  final int maxSize;
  final Duration ttl;
  BookInfo? get(String isbn13);   // 过期返回 null 并移除；命中则 remove+重插提升 LRU 近期性
  void set(String isbn13, BookInfo info);
  void remove(String isbn13);
  void clear();
  int get size;
  bool contains(String isbn13);
}
```
用 `LinkedHashMap<String, _Entry>`；`_Entry` 存 `value` + `expiresAt`。`now` 默认 `DateTime.now`，构造注入以便测试控制时间。

### `isbn_service.dart`（单例，对外 API）
```dart
class IsbnService {
  IsbnService._();
  static final IsbnService instance = IsbnService._();

  Future<BookInfo> lookup(String isbn);      // 抛 IsbnException
  Future<BookInfo?> tryLookup(String isbn);  // 失败返回 null

  @visibleForTesting IsbnCache get cache;
  @visibleForTesting void clearCache();
}
```
`lookup` 流程：
1. `canon = IsbnValidator.canonical(isbn)`；空 → `throw IsbnException(invalidFormat, 'ISBN 格式无效', isbn: isbn)`。
2. `isbn13 = IsbnValidator.toIsbn13(canon)`；空 → `throw IsbnException(invalidFormat, ...)`。
3. `_cache.get(isbn13)` 命中 → 返回。
4. `await _warmUp()`：GET `http://opac.nlc.cn/F`，正则 `http://opac\.nlc\.cn:80/F/[^\s?]*` 验证动态 URL；解析 `Set-Cookie` 头。失败 → `throw IsbnException(sessionError, ...)`。
5. `html = await _fetchDetail(canon)`：URL 用 `_detailTemplate.replaceFirst('{isbn}', canon)` **整串内联**（不走 `queryParameters`，避免 dio URL 编码）；`Options(headers: {..._headers, 'Cookie': cookie?}, responseType: ResponseType.plain)`；走 `HttpService.instance.getRaw<String>`。
6. `!NlcHtmlParser.hasDetailTable(html)` → `throw IsbnException(notFound, ...)`。
7. `fields = NlcHtmlParser.parseDetailTable(html)`；用 `NlcFieldExtractor` 提取各字段；`await ClcDataset.instance.resolveCategory(clcCode)` → `clcCategory = info?.namePath.elementAt(1) ?? info?.name`。
8. `_cache.set(isbn13, book); return book;`
9. `ApiException`/`DioException` → `IsbnException(network, e.message, isbn: isbn13, cause: e)`；其余 → `IsbnException(parseError/unknown, ...)`。

请求头（精确）：`User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...Edg/120.0.0.0`、`Accept-Language: zh-CN,zh;q=0.9,...`、`Accept: text/html,...`、`Accept-Encoding: identity`（参考实现不解压，保险起见）。

---

## CLC 精简数据集（`assets/isbn/clc_compact.json`）

JSON 结构（2 级树）：
```json
{
  "version": "compact-v1",
  "levels": [
    {"code": "A", "name": "马克思主义、列宁主义、毛泽东思想、邓小平理论", "children": [
      {"code": "A1", "name": "马克思、恩格斯著作"},
      {"code": "A2", "name": "列宁著作"},
      ...
    ]},
    {"code": "B", "name": "哲学、宗教", "children": [...]},
    ...
    {"code": "T", "name": "工业技术", "children": [
      {"code": "TB", "name": "一般工业技术"},
      {"code": "TD", "name": "矿业工程"},
      ...
      {"code": "TP", "name": "自动化技术、计算机技术"},
      {"code": "TQ", "name": "化学工业"},
      ...
    ]},
    ...
    {"code": "Z", "name": "综合性图书", "children": [...]}
  ]
}
```
**22 个大类**：A, B, C, D, E, F, G, H, I, J, K, N, O, P, Q, R, S, T, U, V, X, Z。（L, M, W, Y 排除。）

替换为完整数据树：同名文件替换为更深层嵌套树，schema 不变，无需改代码或 pubspec，重跑测试即可。三级 code 届时可解析到非空 `clcCategory`。

---

## 缓存设计

- 类型：内存 `LinkedHashMap<String, _Entry>`。
- 键：规范化 ISBN-13（服务端统一先规范化，10/13 位输入命中同一项）。
- 容量：100 条（可配置）。
- TTL：7 天（可配置）；写入时 `expiresAt = now().add(ttl)`。
- LRU：`get` 命中且未过期 → `remove` + 重 `[]=` 提升近期性；`set` 后 `_evictIfNeeded()` 移除 `keys.first`。
- 过期：`get` 时 `now().isAfter(expiresAt)` → 移除并返回 null。
- 并发：单线程 Dart，无需锁。同一 ISBN 并发查询可能重复请求（v1 可接受，文档说明；未来可加 in-flight `Map<String, Future>`）。

---

## pubspec.yaml 改动

`dependencies:` 下（`flutter_dotenv` 之后）加：
```yaml
  html: ^0.15.4
```
`flutter:` → `assets:` 下加：
```yaml
    - assets/isbn/
```
（`dio`、`freezed_annotation`、`json_annotation`、`crypto`、`flutter_dotenv` 已存在；SDK `>=3.11.0 <4.0.0` 满足。）

---

## 测试计划

### 纯函数测试（无绑定、无 mock）
- **`isbn_validator_test.dart`**：`canonical`（去连字符/空格、末尾 x→X、拒绝 11/12/9/14 位、拒绝全 0、拒绝 X 不在末位）；`checkDigit10('030640615')=='2'`、`'X'` 场景；`checkDigit13('978711154493')=='7'`；`isIsbn10/isIsbn13` 真假例（含 979 前缀、坏校验）；`toIsbn13` 13→13、10→13、非法→`''`。
- **`clc_parser_test.dart`**：传入合成树 `[ClcClass(code:'T',name:'工业技术',children:[ClcClass(code:'TP',name:'自动化技术、计算机技术')])]`；`parse('TP311', tree)` → 一个 ParsedCode(level1:'T', level2:'TP')；`parse('A1', treeWithA)`；`parse('A1；B2', tree)` 两段；`parse('TP311:TP312', tree)` 取首个；`parse('', tree)` 空。
- **`nlc_html_parser_test.dart`**：用 fixture；`hasDetailTable` 真假；`parseDetailTable(fixture)['题名与责任']` 含「深入理解计算机系统」；`&nbsp;` 空首格行追加到上一 label；空 HTML 返回 `{}`。
- **`nlc_field_extractor_test.dart`**：手构 Map 断言各字段（详见下方 fixture 期望）。
- **`book_info_test.dart`/`clc_info_test.dart`**：freezed 相等性、`fromJson` 往返、默认值。

### `isbn_cache_test.dart`
- TTL 过期：注入可控 `now`，set 后时间 +8 天 → `get` 返回 null。
- LRU 驱逐：插入 `maxSize+1` 条 → `contains(最旧)==false`、`size==maxSize`。
- 近期性：get(key1) 后填满再插一条 → 驱逐 key2 而非 key1。

### 服务测试（`isbn_service_test.dart`，复用 `test/services/http_service_test.dart` 的 `_FakeAdapter` 模式）
- `setUp`：`http.setDioForTesting(mockDio)`；`IsbnService.instance.clearCache()`；`ClcDataset.instance.setDatasetForTesting(合成含 T/TP 的树)`。
- `tearDown`：恢复 Dio；`ClcDataset.instance.resetForTesting()`。
- 用例：
  1. **正常路径**：adapter 按 `options.path` 区分（含 `func=find-b` 返回详情 fixture，否则返回含 `http://opac.nlc.cn:80/F/xxx` 的 warm-up HTML）；断言 `isbn13=='9787111544937'`、`title` 含「深入理解计算机系统」、`authors` 非空（含贺莲/龚奕利）、`publisher=='机械工业出版社'`、`pubDate=='2016'`、`clcCode=='TP311'`、`clcCategory=='自动化技术、计算机技术'`。
  2. **缓存命中**：连调两次同 ISBN；第二次 adapter 调用计数不增。
  3. **非法 ISBN**：`lookup('abc')` 抛 `invalidFormat`，无网络调用。
  4. **未找到**：adapter 返回无 `<table id="td">` 的 HTML → 抛 `notFound`。
  5. **会话错误**：warm-up 返回的 HTML 无动态 URL → 抛 `sessionError`。
  6. **网络错误**：`_FakeAdapter.error(DioException(type: connectionTimeout))` → 抛 `network`。
  7. **tryLookup**：未找到场景返回 null 而非抛异常。

### 代表性 HTML fixture（`test/services/isbn/fixtures/nlc_detail_9787111544937.html`）
精简但覆盖每个提取器路径：含 `<table id="td">`，行覆盖题名与责任/著者/出版项/通用数据（`1234567892016...` 使 `\d{9}(\d{4})` 捕获 2016）/内容提要/主题/中图分类号（`TP311`）/ISBN，末尾一行首格为 `&nbsp;` 测试空首格追加逻辑。另在表外加 `<div>ISBN: 978-7-111-54493-7</div>` 测试页内 ISBN 提取。

### `clc_dataset_test.dart`
- `setDatasetForTesting` 合成树；`getClcInfoByCode('TP')` 返回正确 `path/namePath`；`resolveCategory('TP311')` 返回 level2 条目；`resolveCategory('XYZ')` 返回 null。
- 一个集成测试（`TestWidgetsFlutterBinding.ensureInitialized()` 后 `await ClcDataset.instance.reload()`）：验证 shipped `clc_compact.json` 能解析且含 `TP`。

---

## 文档

- **`docs/isbn/README.md`**：模块用途、范围、上游参考链接、快速使用示例（`IsbnService.instance.lookup(...)` + try/catch `IsbnException`）、其余文档指引。
- **`docs/isbn/api.md`**：逐符号参考——`IsbnService.lookup/tryLookup`、`IsbnException`/`IsbnErrorCode`、`IsbnValidator`（含算法）、`NlcHtmlParser`、`NlcFieldExtractor`（含各正则与对应 label）、`ClcParser`、`ClcDataset`、`IsbnCache`、`BookInfo`、`ClcInfo`/`ClcClass`。
- **`docs/isbn/nlc_protocol.md`**：端点 URL 模板、请求头、为何 `Accept-Encoding: identity`、为何 HTTP 非 HTTPS、session/cookie 手动转发、`responseType: ResponseType.plain` 必要性、ISBN 内联 URL（不走 queryParameters，避免编码）、空 filter 参数须保留、Android 明文流量/iOS ATS 说明（模块不改 manifest，仅提示集成方）。
- **`docs/isbn/clc_dataset.md`**：JSON schema、22 大类清单、L/M/W/Y 排除说明、二级解析机制（`namePath[1]`）、**如何替换完整数据树**（同名替换、无代码改动、重跑测试）、运行时编码自检提示。

---

## 构建步骤（在 `c:\Users\bron1117\flutter\wupin` 执行）

1. 改 `pubspec.yaml`（加 `html` 依赖 + `assets/isbn/`）→ `flutter pub get`
2. 创建全部源文件、JSON 资源、HTML fixture、文档
3. 生成 freezed + json_serializable 代码：`dart run build_runner build --delete-conflicting-outputs`（生成 `lib/models/generated/book_info.{freezed,}.dart` 和 `clc_info.{freezed,}.dart`；**必须在跑测试前执行**，测试 import `part` 文件）
4. 跑新增测试：`flutter test test/models/book_info_test.dart test/models/clc_info_test.dart` 与 `flutter test test/services/isbn/`
5. 全量验证：`flutter test`、`flutter analyze`

---

## 关键陷阱（实现须读）

1. **T 是合法大类**（`[N-V]` 含 T）。`TP311` 合法，精简数据集**必须含 T 及其子类 TP**，否则测试书的 `clcCategory` 会错误地为 null。仅 L/M/W/Y 排除。
2. **`build.yaml` 仅覆盖 `lib/models/` 等 4 目录**。freezed 模型必须放 `lib/models/`，否则 codegen 路径错误。非模型代码（服务/解析器）放 `lib/services/isbn/`。
3. **CLC 分级用最长前缀匹配**（非纯字符串截断）。`TP311` → level2=`TP`（不是 `TP3`/`TP31`）。需树驱动。
4. **`\d{0,3}` 三位上限**：`A1234` 仅匹配 `A123`，与参考一致。
5. **URL 整串内联**：NLC 的 `request={isbn}` 与空 `filter_request_N=` 须原样内联到 `path`，**不要**用 `getRaw(url, query:{...})`（dio 会 percent-encode）。
6. **`responseType: ResponseType.plain`**：否则 dio 默认按 JSON 解析 HTML 失败。
7. **`Accept-Encoding: identity`**：参考实现不解压，保险匹配。
8. **HTTP 非 HTTPS**：NLC OPAC 为 `http://opac.nlc.cn`。Android 需允许明文流量（项目疑似已开，WebDAV 等场景；集成时验证 `android/app/src/main/AndroidManifest.xml`）。模块不改 manifest，文档提示集成方。
9. **Cookie 手动转发**：dio 无内置 cookie jar（`dio_cookie_manager` 未引入）。`_warmUp` 读 `headers.map['set-cookie']`，每条取首个 `;` 前，以 `'; '` 拼接，详情请求带 `Cookie` 头。无则不带。
10. **`subjects` 的 `--` 处理**：参考将 `--` 替换为 `&`。本实现选择：`--` 拆分为多元素 `List<String>`（如 `计算机系统--高等学校--教材` → `['计算机系统','高等学校','教材']`），在 `api.md` 明确记录此解读。
11. **warm-up 严格性**：动态 URL 未找到 → `sessionError`。可加 `setStrictWarmUp(bool)`（默认 true）供集成方在 NLC 改版时放宽。
12. **并发重复请求**：缓存 miss 与 set 之间，同 ISBN 并发查询会重复请求，v1 可接受，文档说明。
13. **URL 用 `canon`（可能含 X），缓存键用 `isbn13`（纯数字）**：二者区分。
14. **编码**：fixture 为 UTF-8。若生产响应为 GBK，dio 默认 UTF-8 解码会乱码、解析静默返回空字段。v1 假设 UTF-8；文档说明若发现 `hasDetailTable` 为 true 但无中文 label，可能为编码不匹配，未来可改 `ResponseType.bytes` + GBK codec（需额外依赖，延后）。

---

## 验证（端到端）

- `flutter analyze` 无错误。
- `flutter test test/services/isbn/` 与 `test/models/` 全绿，覆盖：校验函数所有边界、CLC 最长前缀匹配、HTML 解析与字段提取、缓存 LRU/TTL、服务层 7 个用例（含正常路径用 fixture 断言 `clcCategory=='自动化技术、计算机技术'`）。
- `flutter test` 全量套件不回归。
- `ClcDataset` 集成测试验证 shipped `clc_compact.json` 可加载且含 `TP`。
- （可选，需网络）真实查询 `9787111544937` 验证 NLC 端到端。
