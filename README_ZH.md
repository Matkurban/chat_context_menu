# Chat Context Menu

[![English](https://img.shields.io/badge/Docs-English-blue)](README.md)

一个提供 iOS 风格聊天上下文菜单的 Flutter 组件包，支持自定义外观和动画。该组件包处理菜单定位、箭头指示器和背景遮罩/镂空，你只需提供任意 Widget 作为菜单内容。

**在线演示：** https://matkurban.github.io/chat_context_menu/

## 功能特性

*   **iOS 风格上下文菜单：** 流畅的动画和布局，类似原生 iOS 上下文菜单。
*   **两种定位模式（`ChatContextMenuPositionMode`）：**
    *   `ChatContextMenuPositionMode.outside`（默认）：在目标组件或文本选区边界外部计算显示位置；当组件/选区超出屏幕可用空间时自动回退到点击位置。
    *   `ChatContextMenuPositionMode.pointer`：直接以鼠标点击或手指按压坐标作为锚点从点击位置显示菜单，角标直接指向点击位置（`ChatContextMenuWrapper` 与 `ChatSelectableText` 均支持，且同时兼容 `Axis.vertical` 与 `Axis.horizontal`）。
*   **箭头指示器：** 箭头指向目标组件、文本选区或点击坐标，并自动避开圆角区域。
*   **纵向与横向布局：** 支持在锚点上下方（`Axis.vertical`）或左右侧（`Axis.horizontal`）弹出菜单。
*   **自定义外观：** 可配置背景颜色、圆角、内边距、阴影、箭头尺寸和背景遮罩颜色。
*   **灵活的内容与触发方式：** 自由提供菜单内容 Widget，并通过 `widgetBuilder` 提供的 `showMenu` / `hideMenu` 回调绑定任意触发手势（如 `onLongPress`、`onSecondaryTap`、`onTap`、`IconButton` 等）。
*   **可选择文本（`ChatSelectableText`）：** 从底层完全自定义实现的可选择文本组件（`RichText` + `TextPainter` + `OverlayEntry`），支持拖动手柄、边缘自动滚动和浮动上下文菜单。支持长按、双击（选词）、三击（选段）、鼠标右键和桌面端鼠标左键拖动选择。
*   **内置动画样式：** `ChatContextMenuAnimationStyle.scaleFade`（默认，150ms 整页淡入缩放）或 `cupertinoSheet`（335ms 从箭头回弹的 iOS 操作菜单）。可用 `transitionDurations` / `transitionDuration` 覆盖时长，或用 `transitionsBuilder` 完全自定义。
*   **遮罩锚点开孔（可选）：** 将 `excludeAnchorFromBarrier` 设为 `true` 且 `barrierColor` 非全透明时，遮罩在锚点处镂空，锚点保持明亮可点，点击半透明暗区可关闭菜单；可用 `barrierAnchorPadding`、`barrierAnchorBorderRadius` 调整开孔大小与圆角。

## 截图

|                    ScreenShot                    |                    ScreenShot                    |                    ScreenShot                    |
|:------------------------------------------------:|:------------------------------------------------:|:------------------------------------------------:|
| ![Screenshot 1](doc/screenshot/screenshot_1.jpg) | ![Screenshot 2](doc/screenshot/screenshot_2.jpg) | ![Screenshot 3](doc/screenshot/screenshot_3.jpg) |

## 开始使用

在 `pubspec.yaml` 中添加 `chat_context_menu`：

```yaml
dependencies:
  chat_context_menu: ^4.2.0
```

## Agent skills

本包随附面向 AI 编程助手的 Agent Skills，覆盖 `ChatContextMenuWrapper` 与 `ChatSelectableText`。在依赖了 `chat_context_menu` 的项目中安装：

```bash
dart run skills@ get
```

使用 `--all` 可跳过交互、安装全部 skill。说明见 [Ship skills with packages](https://dart.dev/tools/pub/package-skills)。

## 用法

使用 `ChatContextMenuWrapper` 包裹你想触发菜单的组件（通常是聊天气泡）。

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:example/app_theme.dart';
import 'package:example/context_menu_pane.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Context Menu',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = [
    "Hello!",
    "How are you?",
    "Try long-pressing or right-clicking on any message.",
    "Like Reply, Copy, Forward, Delete.",
    "It mimics the iOS style context menu.",
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Context Menu')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ChatContextMenuWrapper(
                barrierColor: Colors.black26,
                excludeAnchorFromBarrier: true,
                barrierAnchorBorderRadius: BorderRadius.circular(8),
                backgroundColor: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                positionMode: ChatContextMenuPositionMode.outside,
                shadows: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    blurRadius: 32,
                  ),
                ],
                menuBuilder: (context, hideMenu) {
                  return ContextMenuPane(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    onReplayTap: hideMenu,
                    onForwardTap: hideMenu,
                    onCopyTap: hideMenu,
                    onDeleteTap: hideMenu,
                    onMoreTap: hideMenu,
                    onQuoteTap: hideMenu,
                    onSelectTap: hideMenu,
                  );
                },
                widgetBuilder: (context, showMenu, hideMenu) {
                  return GestureDetector(
                    onLongPress: showMenu,
                    onSecondaryTap: showMenu,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _messages[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: isMe ? colorScheme.onPrimary : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 定位模式（`outside` 与 `pointer`）

默认情况下，`positionMode` 为 `ChatContextMenuPositionMode.outside`（在组件外部计算显示位置）。如果希望鼠标点击或手指按压哪里，就从点击位置直接弹出带角标的菜单，可设置 `positionMode: ChatContextMenuPositionMode.pointer`：

```dart
ChatContextMenuWrapper(
  positionMode: ChatContextMenuPositionMode.pointer,
  axis: Axis.vertical, // 或 Axis.horizontal
  menuBuilder: (context, hideMenu) => MyMenuContent(onClose: hideMenu),
  widgetBuilder: (context, showMenu, hideMenu) {
    return GestureDetector(
      onSecondaryTap: showMenu,
      onLongPress: showMenu,
      child: child,
    );
  },
)
```

## ChatContextMenuWrapper 属性

| 属性                        | 类型                                                                                                   | 默认值                                       | 说明                                                                                     |
|-----------------------------|--------------------------------------------------------------------------------------------------------|----------------------------------------------|------------------------------------------------------------------------------------------|
| `widgetBuilder`             | `ContextMenuWidgetBuilder` (`Widget Function(BuildContext, VoidCallback showMenu, VoidCallback hideMenu)`) | 必填                                         | 锚点组件构建函数（菜单未打开时调用 `hideMenu` 无效果）                                   |
| `menuBuilder`               | `ContextMenuContentBuilder` (`Widget Function(BuildContext, VoidCallback hideMenu)`)                   | 必填                                         | 菜单内容构建函数                                                                         |
| `positionMode`              | `ChatContextMenuPositionMode`                                                                          | `ChatContextMenuPositionMode.outside`        | `outside`：在组件外部计算显示；`pointer`：直接从点击/按压位置显示，角标指向点击坐标       |
| `axis`                      | `Axis`                                                                                                 | `Axis.vertical`                              | 排列方向：`Axis.vertical`（上下方）或 `Axis.horizontal`（左右侧）                        |
| `barrierColor`              | `Color`                                                                                                | `Colors.transparent`                         | 背景遮罩颜色                                                                             |
| `excludeAnchorFromBarrier`  | `bool`                                                                                                 | `false`                                      | 为 `true` 且 `barrierColor` 非全透明时，在锚点区域镂空遮罩                               |
| `barrierAnchorPadding`      | `EdgeInsets`                                                                                           | `EdgeInsets.zero`                            | 在测得的锚点矩形四周扩大或缩小镂空区域                                                   |
| `barrierAnchorBorderRadius` | `BorderRadius?`                                                                                        | `null`                                       | 锚点镂空区域的圆角（建议与气泡 `BorderRadius` 保持一致）                                 |
| `backgroundColor`           | `Color?`                                                                                               | `null`                                       | 菜单容器与角标的背景颜色                                                                 |
| `borderRadius`              | `BorderRadius`                                                                                         | `BorderRadius.all(Radius.circular(8))`       | 菜单容器圆角                                                                             |
| `padding`                   | `EdgeInsets`                                                                                           | `EdgeInsets.all(8)`                          | 菜单容器内边距                                                                           |
| `shadows`                   | `List<BoxShadow>?`                                                                                     | `null`                                       | 菜单容器阴影                                                                             |
| `arrowHeight`               | `double`                                                                                               | `8.0`                                        | 角标高度                                                                                 |
| `arrowWidth`                | `double`                                                                                               | `12.0`                                       | 角标底边宽度                                                                             |
| `spacing`                   | `double`                                                                                               | `6.0`                                        | 菜单（含角标）与组件/点击点之间的间距                                                    |
| `horizontalMargin`          | `double`                                                                                               | `10.0`                                       | 距屏幕（Overlay）左右边缘的最小留白                                                      |
| `topPadding`                | `double`                                                                                               | `kToolbarHeight`                             | 顶部安全区域额外边距（在 `AppBar` 内使用时可设为 `0`）                                   |
| `menuConstraints`           | `BoxConstraints?`                                                                                      | `null`                                       | 菜单容器尺寸约束                                                                         |
| `layoutConstraints`         | `BoxConstraints?`                                                                                      | `null`                                       | 可用屏幕区域约束（用于布局判定）                                                         |
| `requestFocus`              | `bool`                                                                                                 | `false`                                      | 菜单显示时是否获取焦点                                                                   |
| `animationStyle`            | `ChatContextMenuAnimationStyle`                                                                        | `ChatContextMenuAnimationStyle.scaleFade`    | 内置菜单动画（`scaleFade` 150ms 或 `cupertinoSheet` 335ms）                              |
| `transitionsBuilder`        | `Widget? Function(BuildContext, Animation<double>, Animation<double>, Offset, Alignment, Widget)?`     | `null`                                       | 自定义路由动画（非空时覆盖 `animationStyle`）                                            |
| `transitionDurations`       | `Duration?`                                                                                            | `null`（使用 `animationStyle.defaultDuration`） | 菜单动画时长覆盖                                                                         |
| `onClose`                   | `void Function(dynamic result)?`                                                                       | `null`                                       | 菜单关闭时触发的回调                                                                     |
| `useRootNavigator`          | `bool`                                                                                                 | `false`                                      | 是否将菜单路由推到根 `Navigator`（用于嵌套 Navigator / 桌面端多栏布局）                  |

## 使用与注意事项

**带锚点开孔的遮罩（聊天气泡推荐）**

* 将 `barrierColor` 设为非全透明，并显式设置 **`excludeAnchorFromBarrier: true`**。遮罩会在锚点位置**镂空**，并在路由页内增加全屏 dismiss 层，使点击**半透明区域**能稳定关闭菜单（开孔几何同时用于绘制与命中判定）。
* 将 `barrierAnchorBorderRadius` 与气泡 `BoxDecoration.borderRadius` 对齐，否则开孔轮廓与气泡圆角不一致。
* 若需要微调开孔相对锚点的大小，可使用 `barrierAnchorPadding`。

**列表内超长内容**

* 仅在 **`excludeAnchorFromBarrier: true`** 时：`ListView` 等列表中的高气泡仍可能按**全文高度**参与布局；本包在打开菜单前会将锚点全局矩形与**最近滚动视口**（`RenderAbstractViewport`）及 `MediaQuery` 范围求交，避免开孔向下“透”到输入框、底栏等区域。若使用嵌套滚动、自定义视口等特殊结构，请在实际页面中检查效果。

**默认无开孔**

* **`excludeAnchorFromBarrier: false`（默认）** 时为常规模态遮罩：锚点与背景一并被压暗，无镂空、无开孔专用的 in-route dismiss 层。

**包裹范围**

* `ChatContextMenuWrapper` 以包住 `widgetBuilder` 的**整颗**子树尺寸作为锚点。若使用开孔，且只希望小气泡作为锚点，勿在外层包过大容器，以免开孔范围过大。

**嵌套 Navigator / 桌面多栏布局**

* 锚点坐标始终换算到**目标 Navigator 的 Overlay 坐标系**，因此即使锚点位于被 `Transform` 平移、外层有留白壳层的嵌套 `Navigator` 内，菜单也能正确定位。单个全窗 Navigator（常见移动端）时 Overlay 原点即窗口原点，行为不变。
* 若最近 Navigator 的 Overlay 被**裁剪**（如桌面分栏布局：每栏各自的 Navigator 被 `ClipRect` / 裁剪的 `Material` 卡片包裹），请传 **`useRootNavigator: true`**，菜单与遮罩会渲染在根 Overlay 中、覆盖整个窗口、不被栏边界切断。`ChatSelectableText` 对应使用 **`useRootOverlay: true`**。
* `excludeAnchorFromBarrier: true` 时，开孔还会与锚点到 Overlay 之间的所有裁剪祖先（滚动视口、`ClipRect`/`ClipRRect`、裁剪的 `Material`）求交，保证洞不越出气泡所在栏的可见区域。
* 栏滑动动画进行中触发菜单时，锚点位置按触发瞬间快照；菜单不会跟随动画，但保持一致且可正常关闭。

## ChatSelectableText

一个从底层完全自定义实现的可选择文本组件。用户可以长按激活选择，通过拖动手柄调整选区范围，并对选中的文本执行操作。在桌面端还支持鼠标操作：按住左键拖动选择、右键打开菜单、双击选中单词、三击选中整段。

### 基础用法

```dart
ChatSelectableText(
  '长按选择文本并查看上下文菜单。',
  style: TextStyle(fontSize: 16),
  menuBackgroundColor: Colors.white,
  menuShadows: [
    BoxShadow(color: Colors.black12, blurRadius: 32),
  ],
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: selectedText));
            hideMenu();
          },
        ),
        IconButton(
          icon: Icon(Icons.select_all),
          onPressed: selectAll,
        ),
      ],
    );
  },
)
```

### 自定义选中颜色

```dart
ChatSelectableText(
  '自定义选中区域和手柄颜色。',
  style: TextStyle(fontSize: 16),
  selectionColor: Colors.orange.withValues(alpha: 0.35),
  handleColor: Colors.deepOrange,
  menuBackgroundColor: Colors.white,
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Text('选中: $selectedText');
  },
)
```

### 在聊天气泡中使用

```dart
ChatSelectableText(
  message.text,
  style: TextStyle(
    fontSize: 16,
    color: isMe ? Colors.white : Colors.black,
  ),
  selectionColor: isMe
      ? Colors.white.withValues(alpha: 0.3)
      : Colors.blue.withValues(alpha: 0.3),
  handleColor: isMe ? Colors.white : Colors.blue,
  menuBackgroundColor: Colors.white,
  menuShadows: [
    BoxShadow(color: Colors.black12, blurRadius: 32),
  ],
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: () { hideMenu(); }, child: Text('复制')),
        TextButton(onPressed: selectAll, child: Text('全选')),
      ],
    );
  },
  onSelectionChanged: (text) {
    debugPrint('选中: $text');
  },
)
```

### 单词选择模式

```dart
// 长按只选中按压的单词，而非全部文本
ChatSelectableText(
  '长按一个单词只选择该单词。',
  selectAllOnActivate: false,
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: () { hideMenu(); }, child: Text('复制')),
        TextButton(onPressed: selectAll, child: Text('全选')),
      ],
    );
  },
)
```

### 桌面端交互、菜单排列方向与点击位置模式

在桌面平台上，`ChatSelectableText` 开箱即支持鼠标操作：

*   **鼠标拖动** —— 按住左键拖动选择文本，松开后显示菜单；触摸拖动不受影响，仍可正常滚动列表。
*   **鼠标右键** —— 激活选择（遵循 `selectAllOnActivate`）并打开菜单。
*   **双击 / 三击** —— 选中指针下的单词 / 整个段落（以换行符为边界）。

使用 `axis` 可以让菜单显示在选区左右两侧（`Axis.horizontal`）或上下方（`Axis.vertical`）；使用 `positionMode: ChatContextMenuPositionMode.pointer` 可以让菜单及角标直接从点击位置弹出：

```dart
ChatSelectableText(
  '拖动、右键、双击或三击试试。',
  axis: Axis.horizontal, // 菜单显示在左侧/右侧
  positionMode: ChatContextMenuPositionMode.pointer, // 直接从鼠标点击位置显示
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: () { hideMenu(); }, child: Text('复制')),
        TextButton(onPressed: selectAll, child: Text('全选')),
      ],
    );
  },
)
```

### ChatSelectableText 属性

| 属性                   | 类型                                                                                         | 默认值                                    | 说明                                                                                     |
|------------------------|----------------------------------------------------------------------------------------------|-------------------------------------------|------------------------------------------------------------------------------------------|
| `data`                 | `String`                                                                                     | 必填                                      | 文本内容                                                                                 |
| `style`                | `TextStyle?`                                                                                 | `null`                                    | 文本样式（为 `null` 或 `inherit: true` 时与 `DefaultTextStyle` 合并）                    |
| `textAlign`            | `TextAlign`                                                                                  | `TextAlign.start`                         | 文本对齐方式                                                                             |
| `textDirection`        | `TextDirection?`                                                                             | `null`                                    | 文本方向                                                                                 |
| `maxLines`             | `int?`                                                                                       | `null`                                    | 最大行数                                                                                 |
| `overflow`             | `TextOverflow`                                                                               | `TextOverflow.clip`                       | 文本溢出处理方式                                                                         |
| `textScaler`           | `TextScaler`                                                                                 | `TextScaler.noScaling`                    | 文本缩放比例                                                                             |
| `textWidthBasis`       | `TextWidthBasis`                                                                             | `TextWidthBasis.parent`                   | 文本宽度计算基准                                                                         |
| `textHeightBehavior`   | `TextHeightBehavior?`                                                                        | `null`                                    | 首行与末行高度行为                                                                       |
| `strutStyle`           | `StrutStyle?`                                                                                | `null`                                    | 支柱样式                                                                                 |
| `locale`               | `Locale?`                                                                                    | `null`                                    | 区域设置                                                                                 |
| `softWrap`             | `bool`                                                                                       | `true`                                    | 是否自动换行                                                                             |
| `selectAllOnActivate`  | `bool`                                                                                       | `true`                                    | 激活时全选文本（`true`），或只选按压的单词（`false`）                                    |
| `selectionColor`       | `Color?`                                                                                     | 主题色（`30%` 透明度）                    | 选中高亮颜色                                                                             |
| `handleColor`          | `Color?`                                                                                     | 主题色                                    | 拖动手柄颜色                                                                             |
| `handleSize`           | `double`                                                                                     | `16.0`                                    | 手柄尺寸                                                                                 |
| `autoScrollEdgeExtent` | `double`                                                                                     | `0.0`                                     | 拖拽手柄时距视口边缘触发自动滚动的距离                                                   |
| `autoScrollSpeed`      | `double`                                                                                     | `10.0`                                    | 自动滚动速度（每帧像素数）                                                               |
| `enableHapticFeedback` | `bool`                                                                                       | `true`                                    | 首次激活选择时是否触发触感反馈                                                           |
| `menuBuilder`          | `Widget Function(BuildContext, String, VoidCallback, VoidCallback)`                          | 必填                                      | 菜单构建函数（`(context, selectedText, hideMenu, selectAll)`）                           |
| `onSelectionChanged`   | `ValueChanged<String>?`                                                                      | `null`                                    | 选中文本变化回调                                                                         |
| `onMenuClosed`         | `VoidCallback?`                                                                              | `null`                                    | 菜单关闭及取消选择时的回调                                                               |
| `positionMode`         | `ChatContextMenuPositionMode`                                                                | `ChatContextMenuPositionMode.outside`     | `outside`：在选区外部计算显示；`pointer`：直接从点击/按压位置显示，角标指向点击坐标       |
| `axis`                 | `Axis`                                                                                       | `Axis.vertical`                           | 菜单排列方向：上下方（`Axis.vertical`）或左右侧（`Axis.horizontal`）                     |
| `menuBackgroundColor`  | `Color?`                                                                                     | `null`                                    | 菜单背景及角标颜色                                                                       |
| `menuBorderRadius`     | `BorderRadius`                                                                               | `BorderRadius.all(Radius.circular(8))`    | 菜单圆角                                                                                 |
| `menuPadding`          | `EdgeInsets`                                                                                 | `EdgeInsets.all(8)`                       | 菜单内边距                                                                               |
| `menuShadows`          | `List<BoxShadow>?`                                                                           | `null`                                    | 菜单阴影                                                                                 |
| `arrowHeight`          | `double`                                                                                     | `8.0`                                     | 箭头指示器高度                                                                           |
| `arrowWidth`           | `double`                                                                                     | `12.0`                                    | 箭头指示器宽度                                                                           |
| `spacing`              | `double`                                                                                     | `0.0`                                     | 菜单与选区/点击点的额外间距（`outside` 模式下会叠加 `handleSize`）                       |
| `horizontalMargin`     | `double`                                                                                     | `10.0`                                    | 距屏幕（Overlay）左右边缘的最小留白                                                      |
| `useRootOverlay`       | `bool`                                                                                       | `false`                                   | 手柄/菜单/遮罩插入根 `Overlay`（用于嵌套 Navigator 场景）                                |
| `animationStyle`       | `ChatContextMenuAnimationStyle`                                                              | `ChatContextMenuAnimationStyle.scaleFade` | 内置菜单动画（`scaleFade` 或 `cupertinoSheet`）                                          |
| `transitionsBuilder`   | `Widget? Function(BuildContext, Animation<double>, Offset, Alignment, Widget)?`              | `null`                                    | 自定义菜单动画（非空时覆盖 `animationStyle`）                                            |
| `transitionDuration`   | `Duration?`                                                                                  | `null`（使用样式默认时长）                | 菜单动画时长（`scaleFade` 150ms，`cupertinoSheet` 335ms）                                |

## 更多信息

更多详情请查看仓库中的 `example` 文件夹。
