import 'package:flutter/cupertino.dart';

///ContextMenu包裹的组件的定义
typedef ContextMenuWidgetBuilder =
    Widget Function(BuildContext context, VoidCallback showMenu, VoidCallback hideMenu);

///ContextMenu内容的定义
typedef ContextMenuContentBuilder = Widget Function(BuildContext context, VoidCallback hideMenu);
