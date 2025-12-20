# Requirements Document

## Introduction

本项目是一个全栈移动应用，包含 Go (Gin) 后端和 Flutter 前端。核心功能包括：次日计划管理、消费记录追踪、本地化提醒（早睡提醒、周期性喝水提醒）。后端使用 MySQL + GORM + JWT 认证，前端使用 Flutter + Riverpod + Dio。

## Glossary

- **Daily_Planner_System**: 整个应用系统，包含后端 API 服务和 Flutter 移动客户端
- **Backend_Service**: 基于 Go Gin 框架的 REST API 服务
- **Mobile_Client**: 基于 Flutter 的移动应用客户端
- **User**: 系统用户实体，包含手机号和密码
- **Plan**: 次日计划实体，包含计划内容、执行日期和状态
- **Expense**: 消费记录实体，包含金额、分类、备注和时间
- **Reminder**: 提醒设置实体，包含提醒类型、时间和开关状态
- **JWT**: JSON Web Token，用于用户身份认证
- **GORM**: Go 语言的 ORM 库，用于数据库操作
- **Riverpod**: Flutter 状态管理库
- **Dio**: Flutter HTTP 客户端库

## Requirements

### Requirement 1: 用户认证系统

**User Story:** As a 用户, I want to 通过手机号注册和登录系统, so that 我可以安全地访问我的个人数据。

#### Acceptance Criteria

1. WHEN a user submits registration with phone number and password THEN the Backend_Service SHALL hash the password using bcrypt and store the User record in MySQL
2. WHEN a user submits valid login credentials THEN the Backend_Service SHALL generate a JWT token containing the UserID and return it to the Mobile_Client
3. WHEN a user submits invalid login credentials THEN the Backend_Service SHALL return a 401 status code with an error message
4. WHEN a request contains a valid JWT token THEN the Backend_Service SHALL extract the UserID and allow access to protected resources
5. WHEN a request contains an invalid or expired JWT token THEN the Backend_Service SHALL return a 401 status code
6. WHEN the Mobile_Client receives a 401 response THEN the Mobile_Client SHALL redirect the user to the login page

### Requirement 2: 数据库设计与迁移

**User Story:** As a 开发者, I want to 使用 GORM 自动迁移数据库表结构, so that 数据库 schema 能与代码模型保持同步。

#### Acceptance Criteria

1. WHEN the Backend_Service starts THEN the Backend_Service SHALL automatically migrate User, Plan, Expense, and Reminder tables using GORM AutoMigrate
2. WHEN the User table is created THEN the Backend_Service SHALL include columns for ID, phone_number (unique), and hashed_password
3. WHEN the Plan table is created THEN the Backend_Service SHALL include columns for ID, user_id (foreign key), content, execution_date, and status
4. WHEN the Expense table is created THEN the Backend_Service SHALL include columns for ID, user_id (foreign key), amount, category, note, and created_at
5. WHEN the Reminder table is created THEN the Backend_Service SHALL include columns for ID, user_id (foreign key), reminder_type, scheduled_time, and is_enabled

### Requirement 3: 次日计划 CRUD 功能

**User Story:** As a 用户, I want to 创建、查看、更新和删除我的次日计划, so that 我可以规划和追踪我的日常任务。

#### Acceptance Criteria

1. WHEN a user creates a new plan THEN the Backend_Service SHALL associate the plan with the authenticated user's ID and store it in the database
2. WHEN a user queries plans THEN the Backend_Service SHALL return only plans belonging to the authenticated user
3. WHEN a user queries plans without specifying a date THEN the Mobile_Client SHALL default to querying tomorrow's plans
4. WHEN a user updates a plan THEN the Backend_Service SHALL verify the plan belongs to the authenticated user before updating
5. WHEN a user deletes a plan THEN the Backend_Service SHALL verify the plan belongs to the authenticated user before deleting
6. WHEN a user attempts to access another user's plan THEN the Backend_Service SHALL return a 403 status code

### Requirement 4: 消费记录 CRUD 功能

**User Story:** As a 用户, I want to 记录和查看我的消费明细, so that 我可以追踪我的支出情况。

#### Acceptance Criteria

1. WHEN a user creates a new expense record THEN the Backend_Service SHALL associate the expense with the authenticated user's ID and store it in the database
2. WHEN a user queries expense records THEN the Backend_Service SHALL return only expenses belonging to the authenticated user
3. WHEN the Mobile_Client displays expense records THEN the Mobile_Client SHALL show a summary card with total amount at the top and expense details below
4. WHEN a user updates an expense record THEN the Backend_Service SHALL verify the expense belongs to the authenticated user before updating
5. WHEN a user deletes an expense record THEN the Backend_Service SHALL verify the expense belongs to the authenticated user before deleting

### Requirement 5: Flutter 客户端基础架构

**User Story:** As a 开发者, I want to 配置 Flutter 项目的主题和网络层, so that 应用具有统一的视觉风格和可靠的 API 通信。

#### Acceptance Criteria

1. WHEN the Mobile_Client initializes THEN the Mobile_Client SHALL apply FlexColorScheme with Material 3 and a deep blue primary color
2. WHEN the Mobile_Client runs on iOS THEN the Mobile_Client SHALL enable elastic scroll physics
3. WHEN the Mobile_Client makes API requests THEN the ApiService SHALL automatically attach the JWT token in the Authorization header
4. WHEN the ApiService receives a 401 response THEN the ApiService SHALL trigger navigation to the login page
5. WHEN the ApiService is instantiated THEN the ApiService SHALL use singleton pattern to ensure only one instance exists

### Requirement 6: 本地化提醒功能

**User Story:** As a 用户, I want to 设置早睡提醒和周期性提醒, so that 我可以养成良好的生活习惯。

#### Acceptance Criteria

1. WHEN a user enables bedtime reminder THEN the Mobile_Client SHALL schedule a daily notification at the specified time using flutter_local_notifications
2. WHEN a user sets a periodic reminder THEN the Mobile_Client SHALL schedule notifications at the specified interval with custom content
3. WHEN the Mobile_Client displays reminder settings THEN the Mobile_Client SHALL use Cupertino-style time picker for time selection
4. WHEN a user disables a reminder THEN the Mobile_Client SHALL cancel the corresponding scheduled notification
5. WHEN the default bedtime reminder is created THEN the Mobile_Client SHALL set the default time to 23:00

### Requirement 7: iOS 打包与 CI/CD

**User Story:** As a 开发者, I want to 使用 GitHub Actions 自动构建 iOS 应用, so that 我可以在没有 Mac 的情况下生成 .ipa 文件。

#### Acceptance Criteria

1. WHEN code is pushed to the main branch THEN the GitHub Actions workflow SHALL trigger automatically
2. WHEN the workflow runs THEN the workflow SHALL configure Flutter environment and execute flutter build ios --release --no-codesign
3. WHEN the build completes THEN the workflow SHALL compress Runner.app into a downloadable .ipa file
4. WHEN the .ipa file is created THEN the workflow SHALL publish it as a GitHub Release artifact

