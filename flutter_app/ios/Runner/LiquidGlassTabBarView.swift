//
//  LiquidGlassTabBarView.swift
//  Runner
//
//  iOS 26 Native Liquid Glass Tab Bar for Flutter Integration
//  Uses native UIWindow overlay for TRUE transparency (no PlatformView background)
//

import SwiftUI
import Flutter

// MARK: - Overlay Window Manager

@available(iOS 26.0, *)
class LiquidGlassOverlayManager {
    static let shared = LiquidGlassOverlayManager()
    
    private var overlayWindow: UIWindow?
    private var hostingController: UIHostingController<AnyView>?
    private var currentTab: Int = 0
    private var tabChangeCallback: ((Int) -> Void)?
    
    private init() {}
    
    func showTabBar(in windowScene: UIWindowScene, initialTab: Int, onTabChanged: @escaping (Int) -> Void) {
        // Remove existing overlay if any
        hideTabBar()
        
        currentTab = initialTab
        tabChangeCallback = onTabChanged
        
        // Create overlay window
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .normal + 1  // Above main content
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isUserInteractionEnabled = true
        
        // Create SwiftUI tab bar
        let tabBinding = Binding<Int>(
            get: { self.currentTab },
            set: { newValue in
                if self.currentTab != newValue {
                    self.currentTab = newValue
                    self.tabChangeCallback?(newValue)
                }
            }
        )
        
        let tabBarView = FloatingLiquidGlassTabBar(
            selectedTab: tabBinding
        )
        
        let hosting = UIHostingController(rootView: AnyView(tabBarView))
        hosting.view.backgroundColor = .clear
        hosting.view.isOpaque = false
        
        window.rootViewController = hosting
        window.isHidden = false
        window.makeKeyAndVisible()
        
        overlayWindow = window
        hostingController = hosting
    }
    
    func updateTab(_ index: Int) {
        currentTab = index
        refreshView()
    }
    
    func hideTabBar() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
        hostingController = nil
    }
    
    private func refreshView() {
        guard let hosting = hostingController else { return }
        
        let tabBinding = Binding<Int>(
            get: { self.currentTab },
            set: { newValue in
                if self.currentTab != newValue {
                    self.currentTab = newValue
                    self.tabChangeCallback?(newValue)
                }
            }
        )
        
        let tabBarView = FloatingLiquidGlassTabBar(selectedTab: tabBinding)
        hosting.rootView = AnyView(tabBarView)
    }
}

// MARK: - Floating Liquid Glass Tab Bar (positioned at bottom)

@available(iOS 26.0, *)
struct FloatingLiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Tab bar container - NO background, pure glass
                HStack(spacing: 0) {
                    ForEach(0..<4) { index in
                        TabBarItem(
                            index: index,
                            isSelected: selectedTab == index,
                            onTap: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                selectedTab = index
                            }
                        )
                    }
                }
                .frame(height: 72)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 20, y: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 12)
            }
            .ignoresSafeArea()
        }
    }
}

@available(iOS 26.0, *)
struct TabBarItem: View {
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    private var icon: String {
        switch index {
        case 0: return isSelected ? "calendar" : "calendar"
        case 1: return isSelected ? "dollarsign.circle.fill" : "dollarsign.circle"
        case 2: return isSelected ? "drop.fill" : "drop"
        case 3: return isSelected ? "gearshape.fill" : "gearshape"
        default: return "circle"
        }
    }
    
    private var label: String {
        switch index {
        case 0: return "计划"
        case 1: return "记账"
        case 2: return "喝水"
        case 3: return "设置"
        default: return ""
        }
    }
    
    private var color: Color {
        switch index {
        case 0: return Color(hex: "667eea")
        case 1: return Color(hex: "10B981")
        case 2: return Color(hex: "3B82F6")
        case 3: return Color(hex: "F59E0B")
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? color : .secondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ? color.opacity(0.1) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flutter Method Channel Handler

class LiquidGlassTabBarChannel: NSObject {
    static let shared = LiquidGlassTabBarChannel()
    private var channel: FlutterMethodChannel?
    
    func setup(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "liquid_glass_overlay", binaryMessenger: messenger)
        
        channel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 26.0, *) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        switch call.method {
        case "show":
            if let args = call.arguments as? [String: Any],
               let initialTab = args["initialTab"] as? Int {
                showTabBar(initialTab: initialTab)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing initialTab", details: nil))
            }
            
        case "hide":
            LiquidGlassOverlayManager.shared.hideTabBar()
            result(nil)
            
        case "setTab":
            if let args = call.arguments as? [String: Any],
               let index = args["index"] as? Int {
                LiquidGlassOverlayManager.shared.updateTab(index)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing index", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @available(iOS 26.0, *)
    private func showTabBar(initialTab: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        LiquidGlassOverlayManager.shared.showTabBar(
            in: windowScene,
            initialTab: initialTab
        ) { [weak self] index in
            self?.channel?.invokeMethod("onTabChanged", arguments: ["index": index])
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Legacy Platform View Factory (kept for compatibility)

class LiquidGlassTabBarFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return LiquidGlassTabBarPlatformView(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class LiquidGlassTabBarPlatformView: NSObject, FlutterPlatformView {
    private var containerView: UIView
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        // Empty transparent view - real tab bar is in overlay window
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.containerView.isOpaque = false
        super.init()
    }
    
    func view() -> UIView {
        return containerView
    }
}
