//
//  LiquidGlassTabBarView.swift
//  Runner
//
//  iOS 26 Native Liquid Glass Tab Bar for Flutter Integration
//  Uses native SwiftUI TabView with glassEffect - NO BACKGROUND
//

import SwiftUI
import Flutter

// MARK: - Tab Configuration

struct TabConfig {
    let index: Int
    let label: String
    let icon: String
    let activeIcon: String
}

// MARK: - Native Liquid Glass Tab Bar

@available(iOS 26.0, *)
struct NativeLiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let onTabChanged: (Int) -> Void
    
    let tabs: [TabConfig] = [
        TabConfig(index: 0, label: "计划", icon: "calendar", activeIcon: "calendar"),
        TabConfig(index: 1, label: "记账", icon: "dollarsign.circle", activeIcon: "dollarsign.circle.fill"),
        TabConfig(index: 2, label: "喝水", icon: "drop", activeIcon: "drop.fill"),
        TabConfig(index: 3, label: "设置", icon: "gearshape", activeIcon: "gearshape.fill")
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 每个 Tab 内容为完全透明
            ForEach(tabs, id: \.index) { tab in
                Tab(tab.label, systemImage: tab.icon, value: tab.index) {
                    Color.clear
                        .ignoresSafeArea()
                }
            }
        }
        // iOS 26 Liquid Glass 效果 - 关键：移除所有背景
        .tabViewStyle(.sidebarAdaptable)
        .tint(.primary)
        // 确保 Tab Bar 背景完全透明
        .toolbarBackground(.hidden, for: .tabBar)
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
        .background(Color.clear)
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue != newValue {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                onTabChanged(newValue)
            }
        }
    }
}

// MARK: - UIKit Wrapper for SwiftUI

@available(iOS 26.0, *)
class LiquidGlassTabBarController: UIViewController {
    private var selectedTab: Int = 0
    private var onTabChanged: ((Int) -> Void)?
    private var hostingController: UIHostingController<AnyView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isOpaque = false
    }
    
    func configure(initialTab: Int, onTabChanged: @escaping (Int) -> Void) {
        self.selectedTab = initialTab
        self.onTabChanged = onTabChanged
        setupSwiftUIView()
    }
    
    func updateSelectedTab(_ tab: Int) {
        self.selectedTab = tab
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Remove existing hosting controller
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create new SwiftUI view with binding
        let tabBinding = Binding<Int>(
            get: { self.selectedTab },
            set: { newValue in
                self.selectedTab = newValue
                self.onTabChanged?(newValue)
            }
        )
        
        let swiftUIView = NativeLiquidGlassTabBar(
            selectedTab: tabBinding,
            onTabChanged: { [weak self] index in
                self?.onTabChanged?(index)
            }
        )
        // 包装并设置透明背景
        .background(Color.clear)
        .ignoresSafeArea()
        
        let hosting = UIHostingController(rootView: AnyView(swiftUIView))
        hosting.view.backgroundColor = .clear
        hosting.view.isOpaque = false
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 确保 hosting controller 本身也是透明的
        hosting.safeAreaRegions = []
        
        addChild(hosting)
        view.addSubview(hosting.view)
        
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hosting.didMove(toParent: self)
        hostingController = hosting
    }
}

// MARK: - Flutter Platform View

class LiquidGlassTabBarPlatformView: NSObject, FlutterPlatformView {
    private let frame: CGRect
    private let viewId: Int64
    private let channel: FlutterMethodChannel
    private var containerView: UIView
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.frame = frame
        self.viewId = viewId
        self.containerView = UIView(frame: frame)
        // 确保容器透明
        self.containerView.backgroundColor = .clear
        self.containerView.isOpaque = false
        self.channel = FlutterMethodChannel(
            name: "liquid_glass_tab_bar_\(viewId)",
            binaryMessenger: messenger
        )
        
        super.init()
        
        setupView(args: args)
        setupMethodChannel()
    }
    
    func view() -> UIView {
        return containerView
    }
    
    private func setupView(args: Any?) {
        guard #available(iOS 26.0, *) else {
            // Fallback for older iOS versions - 透明背景 + 简单文字
            containerView.backgroundColor = .clear
            let label = UILabel(frame: containerView.bounds)
            label.text = "Requires iOS 26+"
            label.textAlignment = .center
            label.textColor = .systemGray
            containerView.addSubview(label)
            return
        }
        
        let initialTab = (args as? [String: Any])?["initialTab"] as? Int ?? 0
        
        let tabBarController = LiquidGlassTabBarController()
        tabBarController.view.backgroundColor = .clear
        tabBarController.view.isOpaque = false
        
        tabBarController.configure(initialTab: initialTab) { [weak self] index in
            self?.channel.invokeMethod("onTabChanged", arguments: ["index": index])
        }
        
        tabBarController.view.frame = containerView.bounds
        tabBarController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(tabBarController.view)
        
        // Keep reference to prevent deallocation
        objc_setAssociatedObject(containerView, "tabBarController", tabBarController, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard #available(iOS 26.0, *) else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            switch call.method {
            case "setTab":
                if let args = call.arguments as? [String: Any],
                   let index = args["index"] as? Int,
                   let controller = objc_getAssociatedObject(self?.containerView as Any, "tabBarController") as? LiquidGlassTabBarController {
                    controller.updateSelectedTab(index)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

// MARK: - Platform View Factory

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
