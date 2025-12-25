import 'package:flutter/services.dart';

/// 触觉反馈服务
class HapticService {
  /// 轻触反馈 - 用于切换菜单、选择等
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }
  
  /// 中等反馈 - 用于完成任务、记录等
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
  
  /// 重反馈 - 用于重要操作
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
  
  /// 选择反馈 - 用于选择变化
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
  
  /// 振动反馈
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
