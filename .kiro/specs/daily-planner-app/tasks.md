# Implementation Plan

## Phase 1: 后端基础架构

- [x] 1. 初始化 Go 项目结构

  - [x] 1.1 创建项目目录结构 (cmd/, internal/models/, internal/handlers/, internal/middleware/, internal/config/, internal/database/)


    - 初始化 go.mod，添加依赖：gin, gorm, mysql driver, jwt-go, bcrypt
    - _Requirements: 2.1_
  - [x] 1.2 实现配置管理 (internal/config/config.go)

    - 从环境变量读取数据库连接、JWT 密钥等配置
    - _Requirements: 2.1_
  - [x] 1.3 实现数据库连接和自动迁移 (internal/database/database.go)

    - 创建 GORM 连接，实现 AutoMigrate 函数
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 2. 实现数据模型

  - [x] 2.1 创建 User 模型 (internal/models/user.go)

    - 包含 ID, PhoneNumber, Password, CreatedAt, UpdatedAt
    - _Requirements: 2.2_
  - [x] 2.2 创建 Plan 模型 (internal/models/plan.go)

    - 包含 ID, UserID, Content, ExecutionDate, Status, CreatedAt, UpdatedAt
    - _Requirements: 2.3_
  - [x] 2.3 创建 Expense 模型 (internal/models/expense.go)

    - 包含 ID, UserID, Amount, Category, Note, CreatedAt, UpdatedAt
    - _Requirements: 2.4_
  - [x] 2.4 创建 Reminder 模型 (internal/models/reminder.go)

    - 包含 ID, UserID, ReminderType, ScheduledTime, Content, IsEnabled, CreatedAt, UpdatedAt
    - _Requirements: 2.5_

- [x] 3. 实现 JWT 认证系统

  - [x] 3.1 实现 JWT 工具函数 (internal/middleware/jwt.go)

    - GenerateToken: 生成包含 UserID 的 JWT
    - ParseToken: 解析并验证 JWT
    - JWTMiddleware: Gin 中间件，验证请求中的 Token
    - _Requirements: 1.2, 1.4, 1.5_
  - [x] 3.2 编写 JWT 属性测试


    - **Property 2: JWT token contains correct UserID**
    - **Property 4: Invalid JWT rejection**
    - **Validates: Requirements 1.2, 1.4, 1.5**
  - [x] 3.3 实现认证处理函数 (internal/handlers/auth.go)

    - Register: 注册新用户，密码 bcrypt 加密
    - Login: 验证凭据，返回 JWT
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 3.4 编写密码哈希属性测试

    - **Property 1: Password hashing integrity**
    - **Property 3: Invalid credentials rejection**
    - **Validates: Requirements 1.1, 1.3**

- [x] 4. Checkpoint - 确保认证系统测试通过

  - Ensure all tests pass, ask the user if questions arise.

## Phase 2: 后端 CRUD 功能

- [x] 5. 实现计划 CRUD

  - [x] 5.1 实现计划处理函数 (internal/handlers/plan.go)

    - GetPlans: 获取当前用户的计划列表（支持日期过滤）
    - CreatePlan: 创建新计划
    - UpdatePlan: 更新计划（验证所有权）
    - DeletePlan: 删除计划（验证所有权）
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.6_
  - [x] 5.2 编写计划数据隔离属性测试


    - **Property 5: Plan data isolation**
    - **Property 6: Plan ownership verification on mutation**
    - **Validates: Requirements 3.2, 3.4, 3.5, 3.6**


- [ ] 6. 实现消费记录 CRUD
  - [x] 6.1 实现消费处理函数 (internal/handlers/expense.go)

    - GetExpenses: 获取当前用户的消费列表
    - CreateExpense: 创建新消费记录
    - UpdateExpense: 更新消费记录（验证所有权）
    - DeleteExpense: 删除消费记录（验证所有权）
    - _Requirements: 4.1, 4.2, 4.4, 4.5_
  - [x] 6.2 编写消费数据隔离属性测试


    - **Property 7: Expense data isolation**
    - **Property 8: Expense ownership verification on mutation**
    - **Validates: Requirements 4.2, 4.4, 4.5**

- [x] 7. 实现提醒 CRUD

  - [x] 7.1 实现提醒处理函数 (internal/handlers/reminder.go)

    - GetReminders: 获取当前用户的提醒设置
    - CreateReminder: 创建新提醒
    - UpdateReminder: 更新提醒设置
    - DeleteReminder: 删除提醒
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 8. 实现主入口和路由

  - [x] 8.1 创建 main.go (cmd/main.go)

    - 初始化配置、数据库连接
    - 设置 Gin 路由和中间件
    - 启动 HTTP 服务
    - _Requirements: 2.1_

- [x] 9. Checkpoint - 确保后端所有测试通过

  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: Flutter 基础架构

- [x] 10. 初始化 Flutter 项目

  - [x] 10.1 创建 Flutter 项目并配置依赖


    - 添加依赖：flutter_riverpod, dio, flex_color_scheme, flutter_local_notifications
    - _Requirements: 5.1, 5.2_

  - [ ] 10.2 实现主题配置 (lib/config/theme.dart)
    - 使用 FlexColorScheme 配置深蓝色主题
    - 启用 Material 3
    - iOS 弹性滚动效果

    - _Requirements: 5.1, 5.2_


- [ ] 11. 实现网络层
  - [ ] 11.1 实现 ApiService 单例 (lib/services/api_service.dart)
    - 单例模式

    - Dio 拦截器：自动添加 Authorization header
    - 401 响应处理：跳转登录页
    - _Requirements: 5.3, 5.4, 5.5_

  - [x] 11.2 编写 ApiService 属性测试

    - **Property 9: ApiService singleton consistency**
    - **Property 10: JWT token auto-attachment**
    - **Validates: Requirements 5.3, 5.5**

- [x] 12. 实现 Flutter 数据模型

  - [x] 12.1 创建数据模型类 (lib/models/)

    - User, Plan, Expense, Reminder 模型
    - 包含 fromJson/toJson 方法

    - _Requirements: 2.2, 2.3, 2.4, 2.5_

## Phase 4: Flutter 功能页面



- [ ] 13. 实现认证功能
  - [ ] 13.1 创建 AuthProvider (lib/providers/auth_provider.dart)
    - 管理登录状态和 Token 存储
    - _Requirements: 1.2, 1.6_

  - [ ] 13.2 创建登录/注册页面 (lib/screens/login_screen.dart)
    - 手机号和密码输入
    - 登录/注册切换
    - _Requirements: 1.1, 1.2_



- [ ] 14. 实现计划功能
  - [ ] 14.1 创建 PlanProvider (lib/providers/plan_provider.dart)
    - 计划列表状态管理
    - CRUD 操作

    - 默认查询明天的数据
    - _Requirements: 3.1, 3.2, 3.3_
  - [ ] 14.2 创建计划页面 (lib/screens/plan_screen.dart)
    - 计划列表展示

    - FAB 弹出对话框添加新计划
    - 编辑和删除功能
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_


- [x] 15. 实现消费记录功能

  - [ ] 15.1 创建 ExpenseProvider (lib/providers/expense_provider.dart)
    - 消费列表状态管理
    - CRUD 操作
    - 计算总额
    - _Requirements: 4.1, 4.2_
  - [x] 15.2 创建消费页面 (lib/screens/expense_screen.dart)

    - 顶部总额卡片

    - 消费明细列表
    - 添加/编辑/删除功能

    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 16. Checkpoint - 确保核心功能测试通过
  - Ensure all tests pass, ask the user if questions arise.

## Phase 5: 提醒功能



- [ ] 17. 实现本地通知服务
  - [ ] 17.1 创建 NotificationService (lib/services/notification_service.dart)
    - 初始化 flutter_local_notifications
    - scheduleDailyNotification: 每日定时提醒（早睡）
    - schedulePeriodicNotification: 周期性提醒（喝水等）
    - cancelNotification: 取消提醒

    - 默认早睡时间 23:00

    - _Requirements: 6.1, 6.2, 6.4, 6.5_

- [ ] 18. 实现设置页面
  - [x] 18.1 创建 ReminderProvider (lib/providers/reminder_provider.dart)


    - 提醒设置状态管理
    - _Requirements: 6.1, 6.2, 6.4_
  - [ ] 18.2 创建设置页面 (lib/screens/settings_screen.dart)
    - Cupertino 风格时间选择器
    - 早睡提醒开关和时间设置
    - 周期提醒配置（间隔、内容）
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

## Phase 6: CI/CD 配置

- [ ] 19. 配置 GitHub Actions
  - [ ] 19.1 创建 iOS 构建工作流 (.github/workflows/ios-release.yml)
    - 触发条件：push to main
    - 配置 Flutter 环境
    - 执行 flutter build ios --release --no-codesign
    - 压缩 Runner.app 为 .ipa
    - 发布为 GitHub Release artifact
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 20. 实现主入口和导航
  - [ ] 20.1 完善 main.dart
    - 配置 ProviderScope
    - 设置主题
    - 配置路由导航
    - _Requirements: 5.1, 5.2_

- [ ] 21. Final Checkpoint - 确保所有测试通过
  - Ensure all tests pass, ask the user if questions arise.

