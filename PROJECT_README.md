# 每日计划 (Daily Planner) 项目文档

## 项目概述

一个跨平台的日程管理应用，支持 iOS、Android、Windows。包含计划管理、支出记录、喝水提醒等功能。

## 技术栈

- **前端**: Flutter 3.27.0 (Dart)
- **后端**: Go 1.21 (Gin框架)
- **数据库**: MySQL 8.0
- **部署**: Docker + 1Panel

## 项目结构

```
D:\app_code\
├── flutter_app/          # Flutter 前端应用
│   ├── lib/
│   │   ├── screens/      # 页面
│   │   │   ├── home_screen.dart      # 首页
│   │   │   ├── water_screen.dart     # 喝水记录页
│   │   │   ├── plan_screen.dart      # 计划页
│   │   │   └── expense_screen.dart   # 支出页
│   │   ├── services/
│   │   │   ├── api_service.dart      # API 服务
│   │   │   └── notification_service.dart  # 通知服务
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # 认证状态管理
│   │   └── config/
│   │       └── theme.dart            # 主题配置
│   ├── ios/              # iOS 配置
│   │   ├── Runner/
│   │   │   ├── Info.plist           # iOS 配置
│   │   │   └── AppDelegate.swift    # iOS 入口(通知+网络权限)
│   │   └── Podfile                  # iOS 依赖
│   └── pubspec.yaml      # Flutter 依赖
├── backend/              # Go 后端
│   ├── cmd/main.go       # 入口
│   ├── internal/
│   │   ├── config/       # 配置
│   │   ├── database/     # 数据库连接
│   │   ├── handlers/     # API 处理器
│   │   ├── middleware/   # JWT 中间件
│   │   └── models/       # 数据模型
│   ├── Dockerfile        # Docker 构建
│   ├── go.mod
│   └── go.sum
├── docker-compose.yml    # Docker 编排
└── .github/workflows/
    └── ios-release.yml   # iOS 自动构建
```

## 服务器信息

- **IP**: 120.27.115.89
- **后端端口**: 8080
- **MySQL端口**: 3306
- **代码路径**: /opt/flutter_app

## 数据库配置

- **数据库名**: daily_planner
- **用户名**: planner
- **密码**: nagenanren123
- **Root密码**: root

### 数据表

```sql
-- 用户表
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 计划表
CREATE TABLE plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date DATE,
    status ENUM('pending', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 支出表
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    description TEXT,
    expense_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 提醒表
CREATE TABLE reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    remind_time DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API 端点

- `POST /api/auth/register` - 注册
- `POST /api/auth/login` - 登录
- `GET /api/auth/verify` - 验证Token
- `GET/POST/PUT/DELETE /api/plans` - 计划CRUD
- `GET/POST/PUT/DELETE /api/expenses` - 支出CRUD
- `GET/POST/PUT/DELETE /api/reminders` - 提醒CRUD

## 构建命令

### Windows 构建
```powershell
cd D:\app_code\flutter_app
flutter build windows --release
# 输出: build/windows/x64/runner/Release/
```

### iOS 构建
通过 GitHub Actions 自动构建，推送到 main 分支触发。
Artifact 名称: `daily-planner-ipa`

### 后端部署
```bash
cd /opt/flutter_app
docker-compose down
docker-compose up -d --build
docker logs -f daily_planner_backend
```

## 功能特性

1. **用户认证**: JWT Token (30天有效期)，启动时自动验证
2. **喝水记录**: 8种饮品类型，每日目标2000ml，快捷添加按钮
3. **喝水提醒**: 本地通知，可设置提醒时间
4. **计划管理**: 创建/编辑/删除/完成计划
5. **支出记录**: 分类记账

## 已知问题和待优化

1. **iOS 定时通知**: 需要在真机上测试定时提醒是否正常工作
2. **网络权限弹窗**: 已添加 CTCellularData 触发，需真机验证
3. **App图标**: 需要设计并替换默认图标

## 配置文件位置

- Flutter API地址: `flutter_app/lib/services/api_service.dart` (baseUrl)
- JWT密钥: `docker-compose.yml` (JWT_SECRET)
- iOS部署目标: `flutter_app/ios/Podfile` (platform :ios, '12.0')

## GitHub 仓库

https://github.com/qq357877431/flutter_app
