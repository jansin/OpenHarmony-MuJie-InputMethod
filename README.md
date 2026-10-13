# 沐界输入法（MuJie InputMethod）

面向 HarmonyOS 的中文拼音输入法：ArkTS/ArkUI 界面 + NAPI 桥接的 C++ 拼音引擎。

| 项目 | 值 |
| :--- | :--- |
| 应用包名（bundleName） | `com.jason.mujieinput` |
| 工程名 / 版本 | `mujieinput` / `1.0.0`（versionCode `1000000`） |
| 应用显示名 | 沐界输入法（`AppScope` 的 `app_name`） |
| 开发语言 | ArkTS / ArkUI（前端）、C++（拼音引擎，NAPI 暴露） |
| 运行平台 | HarmonyOS（Stage 模型），设备类型 `default`、`tablet` |
| 开源协议 | Apache License 2.0（根目录 [LICENSE](LICENSE) 为全文） |
| 仓库地址 | https://github.com/jansin/OpenHarmony-MuJie-InputMethod |

---

## 一、项目简介

沐界输入法是 OpenHarmony / HarmonyOS 平台的第三方输入法应用，通过系统输入法扩展能力（`InputMethodExtensionAbility`，类型 `inputMethod`）接管软键盘，向任意输入框插入文字。拼音解码不依赖云端：**AOSP 拼音引擎 `pinyinime` 的 C++ 源码内置在工程中**，经 NAPI 编译为 `libime_pinyin`，由独立 Worker 线程解码并生成候选。

目标平台（`build-profile.json5`）：`runtimeOS: HarmonyOS`；`targetSdkVersion: 6.0.0(20)`、`compatibleSdkVersion: 5.0.0(12)`；`apiType: "stageMode"`；`caseSensitiveCheck` 与 `useNormalizedOHMUrl` 均为 `true`；**没有** `compileSdkVersion` 字段。

---

## 二、功能特性

### 2.1 输入法扩展与面板

- `module.json5` 以 `extensionAbilities` 声明 `ServiceExtAbility`（`type: "inputMethod"`、`exported: true`）；扩展类继承 `InputMethodExtensionAbility`，`onCreate` 把 `context` 交给键盘控制器、`onDestroy` 释放；面板由 `createPanel()` 创建并挂载 `pages/Index`。

### 2.2 中文拼音输入

- 引擎经 NAPI 暴露 `nativeIm*` / `nativeSync*` 共 28 个函数（19 + 9），ArkTS 侧由 `PinYinService` 单例封装；状态机 `DecodingInfo.ts` 负责拼音串缓冲、分词、候选分页（`MAX_PAGE_SIZE_DISPLAY = 200`）、预测与选择上屏。
- 解码在独立 Worker（`worker/worker.ts`，已在模块 `build-profile.json5` 的 `sourceOption.workers` 登记）中运行，主线程只做渲染与候选刷新。

### 2.3 键盘布局（26 键 / 数字 / 符号 / Emoji）

`pages/Index.ets` 按 `menuType` 分发：`0` 英文 26 键、`1` 数字、`2` 符号、`3` 中文拼音 26 键（默认）、`4` Emoji；布局数据在 `model/KeyboardKeyData.ets`。

> **关于 9 键**：代码保留 `isNineKey` / `isNineKeyBack` 状态与分支，但 `KeySetView.ets` 启动时强制 `isNineKey = false`，设置项显示「当前仅保留 26 键布局」。当前版本**没有可用的 9 键布局**。

### 2.4 候选词与编辑

- 候选栏 `SelectText.ets` 经 `LazyForEach` 绑定 `ChineseDataSource`，可**展开浏览**（`Grid` + `scrollPage` 翻页）；删除支持**单击删除**与**长按连续删除**（按下 280 ms 后启动，间隔 80 ms）。

### 2.5 中英文切换与标点适配

- 语言切换键 `ChangeItem.ets`：点击在「中/英」与「英/中」间切换，写入 `AppStorage.isChinese` 并切换 `menuType`（`3` ↔ `0`）。
- **没有手动全角/半角开关**：标点由 `common/PunctuationAdapter.ets` 自动适配——中文模式下半角转全角（`,`→`，`、`?`→`？`），`"` 与 `'` 按**开/闭引号配对**输出；英文模式下全角转回半角。

### 2.6 Emoji 输入

- 顶部工具栏笑脸图标进入面板（`menuType = 4`）；**9 个分类 + 「最近使用」**（见 `model/EmojiData.ts`）。面板为 8 列 × 4 行 `Grid`；点击表情**直接上屏**（不经拼音组合）；含删除键与返回键。
- 「最近使用」保留 40 条（`RECENT_LIMIT = 40`）、自动去重，并记忆上次停留的分类。
- **存储方式**：最近使用与当前分类只存放在 `AppStorage`（键 `emojiRecentJson`、`emojiActiveCategory`），即**进程内状态，未落盘持久化，应用重启后不保留**。

### 2.7 主题与外观设置

- 主题支持**浅色 / 深色 / 跟随系统**三态循环；配色集中在 `common/FcitxTheme.ets`。「跟随系统」经 `ConfigurationConstant.ColorMode` 读取宿主色彩模式，由 1.2 s 定时器同步（切换最多约 1.2 s 延迟）。
- 支持**键盘透明度**滑杆（0.1–1.0）；设置面板 `KeySetView.ets` 含基础设置（当前仅 26 键）与外观设置（主题模式、透明度）。

### 2.8 首次使用引导页

- **入口 UIAbility 实际加载的是 `pages/ImeTestPage`**（`EntryAbility.ets` 的 `windowStage.loadContent('pages/ImeTestPage')`），**不是**模板遗留的 `pages/PrivatePreview`。
- 引导两步：**启用沐界输入法** → **切换到沐界输入法**；`aboutToAppear` / `onPageShow` 经 `getInputMethods(true)` 检查启用状态，第一步完成后其按钮置灰、第二步高亮可点。
- 打开系统输入法设置页采用**三级兜底**：设置页 `set_input` → 系统输入法配置 Ability → 系统输入法选择面板。

### 2.9 硬键盘与设备适配

- 监听物理键盘 `keyDown` / `keyUp` / 光标与选区变化，按键码到字符的映射见 `model/HardKeyUtils.ets`（含 Shift 组合大写）；依 `display.getDefaultDisplaySync()` 宽高判定横竖屏并选择键盘高度比例。

---

## 三、技术栈

| 层次 | 技术 |
| :--- | :--- |
| UI / 状态 | ArkTS + ArkUI 声明式 UI（`@Component` / `@Builder` / `Grid` / `LazyForEach`）；`AppStorage` + `@StorageLink` / `@State` / `@Link` |
| 应用模型 | Stage 模型；`UIAbility` + `InputMethodExtensionAbility` |
| 输入法能力 | `@ohos.inputMethodEngine`（`createPanel` / `InputClient.insertText` / `deleteForward`）、`@ohos.inputMethod` |
| 并发 / Native | Worker 多线程（`ThreadWorker`）；C++ + NAPI + CMake 构建 `ime_pinyin`（链接 `libace_napi.z.so`、`libhilog_ndk.z.so`） |
| 拼音引擎 | 内置 AOSP `pinyinime`（词典 trie、LMA 搜索、n-gram、用户词典） |
| 日志 / 构建 / 测试 | `@ohos.hilog`（ArkTS domain `0x300A`，native `0x0201`）；hvigor `modelVersion 5.0.0` + ohpm；`@ohos/hypium` / `@ohos/hamock`（devDependencies） |

---

## 四、目录结构（关键部分）

```text
OpenHarmony-MuJie-InputMethod/
├── AppScope/app.json5              # bundleName / versionCode / versionName / icon / label
├── entry/                          # 唯一业务模块（entry HAP）
│   ├── build-profile.json5         # CMake 入口、Worker 登记、release 构建选项
│   └── src/main/
│       ├── module.json5            # EntryAbility + inputMethod 扩展
│       ├── cpp/                    # C++ 拼音引擎：ime_pinyin.cpp、CMakeLists.txt、
│       │                           #   include/ share/（AOSP pinyinime）、data/（词典源数据）、types/
│       ├── ets/                    # ArkTS 源码
│       │   ├── entryability/EntryAbility.ets            # 入口 UIAbility（加载引导页）
│       │   ├── ServiceExtAbility/ServiceExtAbility.ets  # 输入法扩展（核心入口）
│       │   ├── pages/              # Index（键盘面板）、ImeTestPage（引导）、PrivatePreview
│       │   ├── components/         # 键盘 UI（各 *Menu、SelectText、PinYinView、KeySetView…）
│       │   ├── model/              # KeyboardController、DecodingInfo、PinYinService、EmojiData…
│       │   ├── common/             # FcitxTheme、StyleConfiguration、PunctuationAdapter
│       │   ├── worker/worker.ts    # 拼音解码 Worker
│       │   └── resources/          # element / media / profile；rawfile（词典、emoji_compact.json）
│       └── ohosTest/ test/         # 仪器化测试与本地单元测试
├── hvigor/hvigor-config.json5      # hvigor 配置（modelVersion 5.0.0）
├── shell/Install.bat               # 作者自用刷机脚本（危险，见 5.6）
├── tools/extract_emoji.py          # Emoji 数据生成脚本（从 OpenBoard 提取）
├── build-profile.json5             # 签名、产品、SDK、strictMode、模块
├── oh-package.json5 / -lock.json5  # 包信息与依赖锁定
└── LICENSE                         # Apache License 2.0 全文
```

---

## 五、环境要求与构建运行

### 5.1 环境要求

- **操作系统**：Windows（现有签名配置为 Windows 绝对路径），其他平台需重新配置签名。
- **DevEco Studio / SDK**：需支持 HarmonyOS `5.0.0(12)`（最低，`compatibleSdkVersion`）与 `6.0.0(20)`（`targetSdkVersion`，具体 DevEco 版本号**待补充**）；CMake ≥ 3.4.1 + NDK（随 HarmonyOS SDK 提供）；hvigor `modelVersion: 5.0.0`。
- **Node.js / ohpm**：工程未声明版本约束（无 `engines` 字段，**待补充**），用 DevEco Studio 自带即可。

> **仓库中不含 `hvigorw` / `hvigorw.bat` 包装脚本**（`hvigor/` 下仅有 `hvigor-config.json5`）：命令行构建需自行补充包装脚本，日常开发建议直接用 DevEco Studio 的构建菜单。

### 5.2 获取并打开工程

```bash
git clone https://github.com/jansin/OpenHarmony-MuJie-InputMethod.git
```

DevEco Studio → **Open** → 选择含 `build-profile.json5` 的工程根目录 → 等 **Sync** 完成（ohpm 按 `oh-package.json5` / `oh-package-lock.json5` 拉取依赖）。

### 5.3 签名配置（**必须替换**）

`build-profile.json5` 的 `signingConfigs[0].material` **硬编码了原作者机器的绝对路径与口令**：

```json5
"certpath": "C:\\Users\\86185\\.ohos\\config\\default_MuJieInputMethod_....cer",
"storeFile": "C:\\Users\\86185\\.ohos\\config\\default_MuJieInputMethod_....p12",
"keyPassword": "0000001A...",
"storePassword": "0000001A..."
```

这些路径在你机器上不存在，**直接构建会签名失败**。请在 DevEco Studio 的 **File → Project Structure → Signing Configs** 勾选 **Automatically generate signature**（需登录华为开发者账号），或手动填写自己的 `.p12` / `.cer` / `.p7b` 与口令；保存后该段会被重写。

> **安全提示**：口令与密钥库路径**不应提交到公开仓库**；建议将 `signingConfigs` 抽出为本地配置后再提交，并**轮换已泄露的调试密钥**。

### 5.4 构建与安装

推荐直接用 DevEco Studio 点击 **Run**（自动完成构建、签名、安装、启动）。工程未附带 `hvigorw`；若已自备包装脚本（可从 DevEco Studio 生成的工程复制，或使用其安装目录下的 hvigor）：

```bash
# 构建 HAP（debug），产物路径见下方 install 命令
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
hdc list targets
hdc install -r entry/build/default/outputs/default/entry-default-signed.hap   # 设备需开启 USB 调试
```

### 5.5 在系统设置中启用输入法（输入法类应用必做）

安装后**不会自动成为当前输入法**，必须手动启用：

1. 打开「设置 → 系统 → 输入法」（或「设置 → 输入法」）；
2. 在输入法列表中找到并勾选「**沐界输入法**」；
3. 将当前输入法切换为「沐界输入法」（部分系统需在弹出的输入法选择面板中确认）；
4. 任意输入框获得焦点后，键盘即由沐界输入法接管。

应用内引导页（`pages/ImeTestPage`）提供同样两步的跳转：第一步优先跳转 `set_input` 设置页，失败则回退到系统输入法配置 Ability 与选择面板；第二步调用 `showOptionalInputMethods()`；已启用时第一步按钮置灰、第二步高亮。

### 5.6 已知注意事项

- **文件名大小写不一致**：多数组件以 `import '../common/styleConfiguration'`（小写 s）导入，磁盘文件名却是 `StyleConfiguration.ets`（大写 S）（`pages/Index.ets`、`model/KeyboardController.ets` 等用大写）。大小写不敏感的系统（Windows）可正常编译，但 `build-profile.json5` 已开启 `caseSensitiveCheck: true`，在 Linux/macOS 构建机上**可能报模块找不到**，建议统一为 `StyleConfiguration`。
- **`shell/Install.bat` 请勿直接运行**：该脚本会 `mount -o rw,remount /vendor/soc_platform`、**`rm -rf /data/*`** 后 `reboot`，属破坏性刷机；且目标目录 `/vendor/soc_platform/app/com.mujie.mujieinput/` 仍是**旧包名**，与当前 `com.jason.mujieinput` 不一致。仅可在知情的专用测试设备上、改好路径后使用。

---

## 六、使用说明

- **启用与切换**：见 5.5；日常可在任意输入框长按空格键 / 点击输入法切换图标，或经引导页「第二步」打开系统输入法面板。
- **中文拼音**：默认即中文拼音模式（`aboutToAppear` 重置 `isChinese = true`、`menuType = 3`）；点字母键输入拼音，候选区显示候选词，点击上屏；点候选区右侧「下一组」（`app.media.next`）展开浏览并翻页；垃圾桶图标单击删一字、**长按连续删除**。
- **键盘切换**：`中/英`、`英/中` 切换中英文；`?123` 进数字键盘，`#@￥` 切数字/符号组，`=\<` 进符号键盘，`ABC` / `PY` 返回字母键盘，`back` 返回上一层。
- **Emoji 与设置**：笑脸图标进入 Emoji 面板，顶部依次是分类图标（9 类 + 最近使用）、删除、返回；剪贴板/星形图标或语言区「设置」键打开设置面板，可看键盘布局（「26键」）、循环切换主题模式、拖动滑杆调整透明度（10%–100%）；下拉箭头调用 `hideKeyboardSelf()` 收起键盘。

---

## 七、配置说明

- **`AppScope/app.json5`**：`bundleName: com.jason.mujieinput`、`versionCode: 1000000`、`versionName: "1.0.0"`、`icon: $media:icon_input_logo`、`label: $string:app_name`；`vendor` 仍是模板默认值 `example`（建议改为实际厂商）。
- **`build-profile.json5`**：`signingConfigs` **必须替换**（见 5.3）；`products[0]` 名为 `default`（`targetSdkVersion: 6.0.0(20)`、`compatibleSdkVersion: 5.0.0(12)`、`runtimeOS: HarmonyOS`）；`buildModeSet: [debug, release]`；`strictMode` 两项均 `true`；`modules` 仅 `entry`。
- **`entry/src/main/module.json5`**：`mainElement: EntryAbility`，`deviceTypes: ["default", "tablet"]`；`EntryAbility` 是唯一 UIAbility（带 `entity.system.home`，故有桌面图标），启动页由 `onWindowStageCreate` 决定，当前为 `pages/ImeTestPage`；`ServiceExtAbility` 是唯一扩展能力（`type: "inputMethod"`、`exported: true`）。
- **权限与页面路由**：`module.json5` **未声明任何 `requestPermissions`**，全工程检索不到 `ohos.permission.*`，写入输入框完全依赖输入法框架的 `InputClient`（`insertText` / `deleteForward`）；`main_pages.json` 注册 `pages/Index`、`pages/PrivatePreview`、`pages/ImeTestPage`。
- **`entry/build-profile.json5`**：`externalNativeOptions.path` 指向 `cpp/CMakeLists.txt`；`sourceOption.workers` 登记 `worker/worker.ts`（不登记则 Worker 无法打包）；release 下混淆 `enable: false` 且剥离 native 调试符号；`targets: [default, ohosTest]`。
- **运行期 `AppStorage` 键**：`isChinese`、`themeMode`、`systemDarkMode`、`isKeySet`、`isMoreText`、`pinyin`、`inputStyle`、`emojiRecentJson` / `emojiActiveCategory`（Emoji 最近使用与分类，仅内存）。
- **备份**：`backup_config.json` 为 `{ "allowToBackupRestore": true }`，允许应用数据参与系统备份 / 恢复。
- **资源**：运行时词典 `rawfile/dict_pinyin.dat`（约 1.0 MB，经 `resourceManager.getRawFd()` 交给原生引擎），用户词典为 `filesDir` 下的 `usr_dict.dat`，引擎源数据为 `cpp/data/rawdict_utf16_65105_freq.txt` 与 `valid_utf16.txt`。
- **Emoji 数据**：主用内联的 `model/EmojiData.ts`，`rawfile/emoji_compact.json` 为同源文件（许可问题见第八章）。

---

## 八、第三方依赖与开源许可

### 8.1 ohpm 依赖

| 依赖 | 版本 | 类型 | 用途 |
| :--- | :--- | :--- | :--- |
| `@ohos/hypium` | `1.0.13` | devDependencies | 测试框架 |
| `@ohos/hamock` | `1.0.0` | devDependencies | Mock 框架 |

`dependencies` 为**空对象**，运行期无第三方 ohpm 依赖（锁定见 `oh-package-lock.json5`，来源 `https://ohpm.openharmony.cn/ohpm/`）；`entry/oh-package.json5` 另有**本地**依赖 `"libentry.so": "file:./src/main/cpp/types/libentry"`（工程自带 NAPI 模块）。工程**未引入其他第三方 ArkTS/JS 库**，所用系统能力（`@ohos.inputMethodEngine`、`@ohos.worker`、`@ohos.hilog` 等）为 HarmonyOS SDK 自带，按 SDK 许可使用。

### 8.2 内置（vendored）第三方代码 —— 必须随本项目一同遵守其许可

**（1）AOSP 拼音输入法引擎 `pinyinime` —— Apache License 2.0**

`entry/src/main/cpp/` 下共 **34 个文件**（`include/` 18 个头文件、`share/` 16 个 `.cpp`）**逐文件**带有如下版权头：

```text
Copyright (C) 2009 The Android Open Source Project
Licensed under the Apache License, Version 2.0 (the "License");
```

合规要求：分发本应用时须保留上述版权与许可声明，并附带 Apache-2.0 许可文本。

**（2）`cpp/ime_pinyin.cpp`、`cpp/napi_init.cpp`**：文件头未标注版权或许可（本项目自行编写的 NAPI 桥接 / 模板代码），适用本项目的 Apache-2.0。

**（3）词典与字符数据 —— 文件内无许可声明，待核实**

- `entry/src/main/cpp/data/rawdict_utf16_65105_freq.txt`（约 3.4 MB，拼音词典词条 + 词频）
- `entry/src/main/cpp/data/valid_utf16.txt`（约 32 KB，合法汉字集合）
- `entry/src/main/resources/rawfile/dict_pinyin.dat`（约 1.0 MB，运行时词典二进制）

这三个文件**内部没有许可声明**，虽与 AOSP `pinyinime` 数据同源但**未经核实**，发布前必须确认其许可与再分发条件。**（待核实）**

**（4）Emoji 数据 —— 来源为 OpenBoard（GPL-3.0），许可存在合规风险，待核实**

`tools/extract_emoji.py` 显示，`entry/src/main/resources/rawfile/emoji_compact.json` 是从 **OpenBoard** 的资源文件 `emoji-categories.xml` 提取生成的：

```python
SRC = pathlib.Path("D:/person/openboard/app/src/main/res/values/emoji-categories.xml")
DST = pathlib.Path("D:/person/MuJieInputMethod/entry/src/main/resources/rawfile/emoji_compact.json")
CATEGORY_NAMES = [ "emoji_smileys_emotion", "emoji_people_body", ... ]
EMOJI_LIMIT_PER_CATEGORY = 400
```

同一份分类与表情集合也被**内联在** `entry/src/main/ets/model/EmojiData.ts`（9 个分类常量 + `EMOJI_CATEGORY_ORDER`）。

**OpenBoard 项目本身采用 GPL-3.0**（其 Emoji 数据又源自 AOSP 的 emoji 资源）。因此这批 Emoji 数据的**可用许可必须逐项核实，不能默认沿用本项目的 Apache-2.0**。**（待补充：需确认 OpenBoard 仓库中 `emoji-categories.xml` 的确切许可与署名要求，并在此处补充完整署名。）**

---

## 九、开源协议

本项目采用 **Apache License 2.0**，仓库根目录的 [LICENSE](LICENSE) 为协议全文（11556 字节）。要点：

- **允许**商用、修改、分发、私用与专利授权；
- **必须**保留版权声明与许可声明，在修改过的文件中标注修改，并在分发时附带许可副本；
- 提供**明确的专利授权**（含专利 retaliation 条款）；**不提供任何担保**，作者不承担因使用本软件产生的责任；
- 再分发本项目内置的第三方代码（见第八章）时，还须同时遵守其各自的许可。

协议全文：http://www.apache.org/licenses/LICENSE-2.0

> 待办：`oh-package.json5` 中的 `"license"` 字段当前为**空字符串**，建议填写为 `"Apache-2.0"`，以与仓库 LICENSE 保持一致。

---

## 十、贡献指南

欢迎提交 Issue 与 Pull Request。Issue 请写清复现步骤、HarmonyOS 版本、设备型号与 hilog 日志（domain `0x300A`，或原生侧 `0x0201` / tag `imePinYin`）。代码请沿用现有 ArkTS 写法（`AppStorage` 状态、`FcitxTheme` 取色、`StyleConfiguration` 尺寸）；新增文件保留 Apache-2.0 文件头，引入第三方代码或数据前先确认许可并在第八章登记。**不要提交**签名证书、口令或本机绝对路径；PR 请附构建通过说明与改动说明。

---

## 十一、联系方式与致谢

- 作者 / 项目主页（GitHub）：https://github.com/jansin ；问题反馈请在本仓库提交 Issue。
- 致谢：**The Android Open Source Project**（内置拼音引擎 `pinyinime`，Apache License 2.0）。
- 致谢：**OpenBoard**（Emoji 分类与表情数据经 `tools/extract_emoji.py` 自其资源提取，许可待核实，见第八章）、**Huawei / OpenHarmony 社区**（输入法扩展能力与 DevEco Studio 工具链）。
