# iOS 26 Liquid Glass Tab Bar Demo

## 项目概述

本项目是一个独立的 SwiftUI Demo，展示 iOS 26 Liquid Glass（流体玻璃）设计语言的底部导航栏实现。

## 已完成功能

### 1. Metaball（元球）流体效果
- 基于距离场（Distance Fields）的元球算法
- 多个元球之间的平滑融合
- 动态颜色混合

### 2. 触控感应形变
- 手指接近时产生物理张力效果
- 图标跟随触控点偏移
- 弹性动画反馈

### 3. Glass Morphism 玻璃态效果
- `.ultraThinMaterial` 毛玻璃背景
- 动态高光和边缘光
- 微妙的噪点纹理

### 4. Metal 着色器
- `liquidGlassNoise` - 动态噪点纹理
- `metaballField` - 元球场渲染
- `glassRefraction` - 玻璃折射效果
- `specularHighlight` - 镜面高光

## 项目结构

```
LiquidGlassDemo/
├── LiquidGlassDemo.xcodeproj/
│   └── project.pbxproj
└── LiquidGlassDemo/
    ├── LiquidGlassDemoApp.swift    # App 入口
    ├── ContentView.swift            # 根视图
    ├── Components/
    │   ├── LiquidGlassTabBar.swift  # 核心流体导航栏
    │   ├── MetaballRenderer.swift   # 元球算法
    │   ├── TouchInteractionModifier.swift  # 触控追踪
    │   └── TabItem.swift            # Tab 数据模型
    ├── Views/
    │   ├── HomeView.swift
    │   ├── SearchView.swift
    │   ├── ProfileView.swift
    │   └── SettingsView.swift
    ├── Shaders/
    │   └── LiquidGlassShaders.metal # Metal 着色器
    └── Assets.xcassets/
```

## 编译方式

### 通过 GitHub Actions（推荐）

项目已配置 `.github/workflows/build-liquid-glass.yml`，推送到 GitHub 后会自动触发构建：

1. 将代码推送到 GitHub 仓库
2. 进入 Actions 页面查看构建状态
3. 构建成功后下载 `LiquidGlassDemo-unsigned.ipa`

### 本地命令行编译（需要 Mac）

```bash
cd LiquidGlassDemo
xcodebuild build \
  -project LiquidGlassDemo.xcodeproj \
  -scheme LiquidGlassDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## 下一步

根据验证结果选择：
- **方案 A**: 通过 `PlatformView (UIKitView)` 将原生组件嵌入现有 Flutter 项目
- **方案 B**: 将整个 Flutter 业务逻辑全量重构为 SwiftUI 原生项目

## 技术要点

| 特性 | 实现方式 |
|------|----------|
| 流体形变 | `DragGesture` + `interactiveSpring` 动画 |
| 元球算法 | 逆平方距离场 + 阈值检测 |
| 玻璃效果 | `.ultraThinMaterial` + Metal 着色器 |
| 触控反馈 | `UIImpactFeedbackGenerator` |
| 动态高光 | Canvas 绘制 + 径向渐变 |

## 配置说明

- **iOS 部署目标**: iOS 26.0
- **Swift 版本**: 5.0
- **Xcode 版本**: 16.0+
- **Bundle ID**: `com.example.LiquidGlassDemo`（可修改）
