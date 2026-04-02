///移动端菜单触发方式
///Menu trigger mode for mobile platforms
enum MobileTriggerMode {
  ///单击触发
  ///Trigger on single tap
  tap,

  ///双击触发
  ///Trigger on double tap
  doubleTap,

  ///长按触发
  ///Trigger on long press
  longPress,
}

///桌面端菜单触发方式 (鼠标按键)
///Menu trigger mode for desktop platforms (mouse button)
enum DesktopTriggerMode {
  ///右键触发
  ///Trigger on right click (secondary button)
  rightClick,

  ///左键触发
  ///Trigger on left click (primary button)
  leftClick,
}
