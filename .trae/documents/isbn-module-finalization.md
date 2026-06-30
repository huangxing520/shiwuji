# ISBN 模块收尾计划

## 摘要

ISBN 解析功能模块（参照 NLCISBNPlugin 移植，通过中国国家图书馆 OPAC 按 ISBN 查询图书元数据）的主体开发已完成：8 个源文件、7 个测试文件（106 tests 全绿）、2 个 freezed 模型、1 份 CLC 精简数据集、1 份 NLC 详情页测试 fixture 均已就位。

本计划仅覆盖**收尾三项**：
1. 修复 `ClcClass.toJson()` 不递归序列化 `children` 的 bug（测试发现，用户已批准修复源码）
2. 创建 4 篇文档（`docs/isbn/`）
3. 验证（`flutter analyze` + 定向测试 + 全量回归）

不改动现有 UI、不接入「添加物品」书籍流程，不扩展功能范围。

---

## 当前状态分析

### 已完成（只读验证，本轮不修改）

**源文件**（`lib/services/isbn/`，8 个）：
- `isbn_exception.dart` — `IsbnErrorCode` enum + `IsbnException`
- `isbn_validator.dart` — `IsbnValidator` 静态方法（canonical / checkDigit10 / checkDigit13 / isIsbn10 / isIsbn13 / toIsbn13）
- `nlc_html_parser.dart` — `NlcHtmlParser.hasDetailTable` / `parseDetailTable`
- `nlc_field_extractor.dart` — `NlcFieldExtractor` 各字段提取 + `kLabel*` 常量
- `clc_parser.dart` — `ClcParser.parse` + `ClcParsedCode`（最长前缀匹配分级）
- `clc_dataset.dart` — `ClcDataset.instance` 懒加载单例（rootBundle → 扁平查找表）
- `isbn_cache.dart` — `IsbnCache`（LRU + TTL，LinkedHashMap 实现）
- `isbn_service.dart` — `IsbnService.instance.lookup` / `tryLookup`（对外 API）

**模型**（`lib/models/`，2 个）：
- `book_info.dart` — `BookInfo` freezed 模型（isbn13 / title / authors / publisher / pubDate / synopsis / subjects / clcCode / clcCategory / sourceUrl / rawFields）
- `clc_info.dart` — `ClcClass`（递归树节点）+ `ClcInfo`（扁平查找结果）

**资源**：
- `assets/isbn/clc_compact.json` — 精简 CLC 数据集（22 大类 + 221 条二级子类，T 含 TP 等 16 个）

**测试**（`test/services/isbn/` + `test/models/`，9 个文件）：
- `isbn_validator_test.dart`（26 tests ✓）
- `clc_parser_test.dart`（13 tests ✓）
- `nlc_html_parser_test.dart`（13 tests ✓）
- `nlc_field_extractor_test.dart`（24 tests ✓）
- `clc_dataset_test.dart`（9 tests ✓）
- `isbn_cache_test.dart`（9 tests ✓）
- `isbn_service_test.dart`（12 tests ✓）
- `book_info_test.dart`（9 tests ✓）
- `clc_info_test.dart`（7 tests，**1 个失败**）—— 见下文 bug

### 待修复的 bug

**失败测试**：`test/models/clc_info_test.dart` 的 `ClcClass toJson / fromJson 往返`。

**根因**：`lib/models/generated/clc_info.g.dart` 中生成的 `_$ClcClassToJson` 直接输出 `'children': instance.children`（`List<_ClcClass>` 对象），未递归调用 `.toJson()`。这是 `json_serializable` 对自引用递归类型的默认行为——需显式 `explicitToJson: true` 才会递归。

**影响范围**：
- 生产路径**不受影响**：`ClcDataset._load()` 仅调用 `ClcClass.fromJson`（读 JSON 文件 → 对象树），从不调用 `toJson`。
- `ClcInfo` 不受影响：其字段均为基本类型（`List<String>`），无嵌套模型对象。
- 项目其它模型不受影响：`storage.dart`、`book_info.dart` 等均无嵌套模型对象，不需要 `explicitToJson`。

**用户决策**：修复源码（给 `ClcClass` 加 `@Freezed(explicitToJson: true)` 并重新生成）。

---

## 提议变更

### 变更 1：修复 ClcClass.toJson 递归序列化

**文件**：`lib/models/clc_info.dart`

**改动**：将 `ClcClass` 上的 `@freezed`（第 10 行）替换为 `@Freezed(explicitToJson: true)`。

```dart
@Freezed(explicitToJson: true)
abstract class ClcClass with _$ClcClass {
  // ... 其余不变
}
```

**为什么**：`@Freezed` 注解的 `explicitToJson` 参数会透传给 `@JsonSerializable`，使生成的 `_$ClcClassToJson` 对 `children` 递归调用 `.toJson()`。这是 freezed 官方文档推荐的递归类型处理方式。

**不改 `ClcInfo`**：它无嵌套模型对象，保持 `@freezed` 即可，避免不必要的生成代码变动。

**重新生成**：
```bash
dart run build_runner build --delete-conflicting-outputs
```
预期仅重新生成 `lib/models/generated/clc_info.g.dart`（及可能的 `.freezed.dart`）。生成后 `_$ClcClassToJson` 应变为：
```dart
'children': instance.children.map((e) => e.toJson()).toList(),
```

**验证**：`test/models/clc_info_test.dart` 的 7 个 tests 全部通过。

### 变更 2：创建 4 篇文档

新建目录 `docs/isbn/`，含 4 个 Markdown 文件。文档语言：中文（与项目惯例一致），代码标识符用英文。

#### 2.1 `docs/isbn/README.md` — 模块总览与快速上手
- 模块定位：通过 NLC OPAC 按 ISBN 查询图书元数据，参照 NLCISBNPlugin 移植
- 架构总览：8 个源文件 + 2 模型 + CLC 数据集，数据流（校验 → 缓存 → 会话预热 → 拉详情 → 解析 HTML → 提取字段 → 解析 CLC → 写缓存 → 返回 BookInfo）
- 快速上手代码示例：
  ```dart
  try {
    final book = await IsbnService.instance.lookup('9787111544937');
    print('${book.title} / ${book.authors.join(', ')} / ${book.publisher}');
  } on IsbnException catch (e) {
    // 按 e.code 区分处理
  }
  ```
  以及 `tryLookup` 容错版本
- 链接到 `api.md`、`nlc_protocol.md`、`clc_dataset.md`

#### 2.2 `docs/isbn/api.md` — API 参考
按文件逐一列出公开 API（方法签名 + 参数 + 返回 + 用途），覆盖：
- `IsbnService`：`instance`、`lookup`、`tryLookup`、`clearCache`、`cache`、`warmUpUrl`、`detailTemplate`、`headers`、`dynamicUrlRe`
- `IsbnValidator`：`canonical`、`checkDigit10`、`checkDigit13`、`isIsbn10`、`isIsbn13`、`toIsbn13`（含 mod-11 / mod-10 算法说明）
- `IsbnException` + `IsbnErrorCode`（6 种错误码语义）
- `IsbnCache`：构造参数（maxSize=100、ttl=7d、now）、`get`/`set`/`remove`/`clear`/`size`/`contains`、LRU+TTL 行为说明
- `NlcHtmlParser`：`hasDetailTable`、`parseDetailTable`
- `NlcFieldExtractor`：`title`/`authors`/`publisher`/`pubDate`/`synopsis`/`subjects`/`clcCode`/`isbn13FromPageText` + `kLabel*` 常量 + 「与参考实现的差异：保留译者」说明
- `ClcParser`：`parse`、`ClcParsedCode`（raw/level1/level2/level3/isEmpty）、大类正则说明（`[N-V]` 含 T，排除 L/M/W/Y）
- `ClcDataset`：`instance`、`assetPath`、`ensureLoaded`、`reload`、`getClcInfoByCode`、`resolveCategory`、`setDatasetForTesting`、`resetForTesting`
- `BookInfo`：全部字段及来源
- `ClcClass` / `ClcInfo`：字段说明

#### 2.3 `docs/isbn/nlc_protocol.md` — NLC OPAC 协议笔记
- 入口：`http://opac.nlc.cn/F`（Aleph 系统）
- 会话预热：GET 入口页 → 校验动态 URL 正则 `http://opac\.nlc\.cn:80/F/[^\s?]*` → 提取 Set-Cookie
- 详情查询 URL 模板：`func=find-b&find_code=ISB&request={isbn}&local_base=NLC01&filter_code_1=WLN&...`（ISBN 原样内联避免 dio 编码）
- 请求头：User-Agent（Edge/Chrome）、Accept、Accept-Language、`Accept-Encoding: identity`（避免压缩）
- HTML 结构：`<table id="td">` 内 `<tr>` 每行两个 `<td class="td1">`（label/value），首格空时续写到上一 label（`\n` 连接）
- 错误模式：sessionError（无动态 URL）、notFound（无 table#td）、network（ApiException/DioException 包装）
- 参考实现：https://github.com/DoiiarX/NLCISBNPlugin

#### 2.4 `docs/isbn/clc_dataset.md` — CLC 数据集说明
- CLC 是什么（中国图书馆分类法）
- 精简数据集格式：
  ```json
  {"version":"compact-v1","levels":[{"code":"A","name":"...","children":[{"code":"A1","name":"...","children":[]},...]},...]}
  ```
- 当前范围：22 大类 + 221 条二级子类；T 大类含 16 个子类（含 TP「自动化技术、计算机技术」）
- `ClcDataset` 加载流程：rootBundle 读 JSON → `ClcClass.fromJson` 递归建树 → `_walk` 递归构建 `code → ClcInfo` 扁平表
- `ClcParser.parse` 策略：`;`/`；` 拆分 → 大类正则清洗 → 最长前缀匹配三级分级
- `resolveCategory` 流程：parse → 优先 level2 查找 → 回退 level1
- **替换为完整数据树**：覆盖 `assets/isbn/clc_compact.json` 为更深层嵌套 JSON 即可，无需改代码（`ClcClass` 递归结构、`ClcParser` 最长前缀匹配均支持任意深度）
- 资源路径常量：`ClcDataset.assetPath = 'assets/isbn/clc_compact.json'`

### 变更 3：验证

**步骤 1 — 静态分析**：
```bash
flutter analyze lib/services/isbn lib/models/book_info.dart lib/models/clc_info.dart test/services/isbn test/models/book_info_test.dart test/models/clc_info_test.dart
```
预期无 error。

**步骤 2 — 定向测试（ISBN 模块 + 模型）**：
```bash
flutter test test/services/isbn test/models/book_info_test.dart test/models/clc_info_test.dart
```
预期：原 106 tests 全绿 + 修复后 `clc_info_test.dart` 7 tests 全绿 = 113 tests 全绿。

**步骤 3 — 全量回归**：
```bash
flutter test
```
确认 build_runner 重新生成未波及其它模型/测试。重点关注 `test/models/`、`test/database/`、`test/services/` 下与 freezed/json 相关的测试。

---

## 假设与决策

1. **toJson bug 修复方式**：用户已批准「修复源码」——给 `ClcClass` 加 `@Freezed(explicitToJson: true)`，不动 `ClcInfo`，不动 `build.yaml` 全局配置（避免影响其它模型）。
2. **文档语言**：中文正文 + 英文代码标识符，与项目惯例一致。
3. **文档范围**：仅本模块，4 篇；不为整个项目建 `docs/` 索引。
4. **不接入 UI**：本计划不含「添加物品」书籍流程的接入，仅交付模块 + 文档 + 测试。
5. **build_runner 风险**：若重新生成波及其它 `.g.dart`（理论上不会，因 `build.yaml` 的 `build_extensions` 已固定输出路径），以 `git diff` 审查生成文件变动，仅 `clc_info.g.dart` 应有实质改动。若发现意外变动，回滚后改用方案 A（调整测试）作为回退。

---

## 验证清单

- [ ] `lib/models/clc_info.dart`：`ClcClass` 改为 `@Freezed(explicitToJson: true)`，`ClcInfo` 保持 `@freezed`
- [ ] `dart run build_runner build --delete-conflicting-outputs` 成功；`git diff` 确认仅 `clc_info.g.dart` 实质变动
- [ ] `test/models/clc_info_test.dart` 7 tests 全绿
- [ ] `docs/isbn/README.md`、`api.md`、`nlc_protocol.md`、`clc_dataset.md` 创建完成
- [ ] `flutter analyze`（定向）无 error
- [ ] `flutter test test/services/isbn test/models/book_info_test.dart test/models/clc_info_test.dart` 全绿（113 tests）
- [ ] `flutter test` 全量回归通过
