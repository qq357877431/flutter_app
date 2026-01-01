开发意向书：基于 iOS 26 Liquid Glass 的跨平台重构方案
1. 当前项目背景
当前状态：项目已使用 Flutter 开发完成，并已通过自定义证书签名安装至 iPhone 实测。

开发环境：目前处于 Windows 环境，无实体 Mac。

构建路径：计划利用 GitHub Actions (macOS Runner) 作为云端编译器构建 IPA。

2. 核心技术痛点：Liquid Glass 适配
目标效果：适配 iOS 26 引入的 Liquid Glass（流体玻璃） 设计语言。

视觉要求：

底部导航栏（Tab Bar）与系统 Home Indicator 的流体融合。

基于距离场（Distance Fields）的交互形变（手指接近时产生物理张力）。

高质量的实时高斯模糊与动态着色器（Shaders）反馈。

技术判断：原生 SwiftUI 在调用 iOS 26 系统底层渲染能力（如 ShaderLibrary）方面具有 Flutter 无法模拟的优势，因此决定进行原生化重构。

3. 开发策略：验证驱动重构
独立 Demo 阶段：

新建一个纯 SwiftUI 项目。

由 Antigravity 生成核心的 Liquid Glass Tab Bar 代码。

通过 GitHub Actions 盲跑构建并进行真机视觉验证。

集成/重构阶段：

方案 A：验证成功后，通过 PlatformView (UIKitView) 将原生组件嵌入现有 Flutter 项目。

方案 B：若原生体验极佳，则利用 Antigravity 将整个 Flutter 业务逻辑全量重构为 SwiftUI 原生项目。

4. 对 Antigravity 的具体指令请求
A. 基础代码生成
请根据以下逻辑生成 SwiftUI 代码：

架构：符合 iOS 26 规范的根视图结构。

效果：实现基于 Metaballs（元球） 算法的流体导航栏。

交互：包含手指触控感应的形变逻辑。

兼容性：代码需能直接在最新的 Xcode 环境下通过命令行（xcodebuild）编译。

B. 项目配置辅助（针对无 Mac 环境）
请协助生成或修改 .pbxproj 配置信息，或提供 xcodegen 的 project.yml 配置，以确保在 GitHub Actions 环境下能正确识别新添加的 .swift 文件及 Metal 着色器文件。