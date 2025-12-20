import Flutter
import UIKit
import CoreTelephony
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 请求网络权限（中国大陆 iOS 要求）
    requestNetworkPermission()
    
    // 请求通知权限
    requestNotificationPermission()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 触发网络权限弹窗
  private func requestNetworkPermission() {
    let cellularData = CTCellularData()
    cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
      switch state {
      case .restricted:
        print("网络权限被限制")
      case .notRestricted:
        print("网络权限已授予")
      case .restrictedStateUnknown:
        print("网络权限状态未知")
      @unknown default:
        break
      }
    }
  }
  
  // 请求通知权限
  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("通知权限已授予")
      } else {
        print("通知权限被拒绝")
      }
    }
  }
}
