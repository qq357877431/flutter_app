# 更新日志

## 2024-12-23 UI 现代化 & 通知个性化

### UI 现代化改进
- **颜色系统优化** (`flutter_app/lib/config/colors.dart`)
  - 深色模式下按钮、渐变色自动变暗（不再刺眼）
  - 移除紫色渐变，改用柔和的蓝绿色系
  - 头像背景改为透明

- **设置页面** (`flutter_app/lib/screens/settings_screen.dart`)
  - 所有设置区块（外观、提醒、账户安全、关于）统一 16px 圆角
  - 早睡提醒时间选择器改为现代底部弹窗样式
  - 退出登录对话框改为现代底部弹窗（带图标、标题、描述）

- **记账页面** (`flutter_app/lib/screens/expense_screen.dart`)
  - 日期筛选器改为现代底部弹窗样式（CupertinoPicker）
  - 重置按钮缩小，分类标签缩小
  - 卡片统一圆角

- **每日计划页面** (`flutter_app/lib/screens/plan_screen.dart`)
  - 进度圆环显示 "已完成/总数" 格式（如 "2/5"），不再显示百分比
  - 日期选择器改为现代底部弹窗样式

### 通知个性化
- **喝水提醒** (`flutter_app/lib/services/notification_service.dart`)
  - 标题: "哈喽 [用户昵称] 👋"
  - 内容: 随机俏皮文案 + emoji（如 "记得补充水分哦~ 💧"）

- **计划任务提醒** (新功能)
  - 当任务未全部完成时，每小时提醒一次（9:00-21:00）
  - 标题: "哈喽 [用户昵称] 📋"
  - 内容: 随机鼓励文案（如 "今日计划还没完成哦，加油！💪"）
  - 任务全部完成后自动取消提醒

### Bug 修复
- **通知用户名显示问题**: 修复喝水/计划提醒不显示用户昵称的问题
  - 原因: 之前从 SharedPreferences 读取用户名，但用户信息存储在 authProvider 中
  - 解决: 改为从 `ref.read(authProvider).user` 获取用户昵称
  - 文件: `water_screen.dart`, `plan_screen.dart`

### 涉及文件
- `flutter_app/lib/config/colors.dart`
- `flutter_app/lib/screens/settings_screen.dart`
- `flutter_app/lib/screens/expense_screen.dart`
- `flutter_app/lib/screens/plan_screen.dart`
- `flutter_app/lib/screens/water_screen.dart`
- `flutter_app/lib/services/notification_service.dart`

---

## 2024-12-22 喝水提醒修复 & UI 美化

### Bug 修复
- **喝水提醒问题**: 修复中午后不再提醒的问题
  - 原因: 之前使用 `zonedSchedule` 只设置一次性提醒，过了时间就不再触发
  - 解决: 改用 `scheduleDailyNotification` 为每个时间点设置每日重复提醒
  - 文件: `flutter_app/lib/services/notification_service.dart`

### UI 美化 (参考 OKX 设计风格)
- **颜色系统重构** (`flutter_app/lib/config/colors.dart`)
  - 新增深色主题优化配色
  - 添加玻璃态效果装饰
  - 添加卡片装饰方法
  - 更现代的渐变色配置

- **首页导航栏** (`flutter_app/lib/screens/home_screen.dart`)
  - 添加选中动画效果
  - 更简洁的图标和标签设计
  - 优化深色模式适配

- **喝水页面** (`flutter_app/lib/screens/water_screen.dart`)
  - 新增波浪动画进度指示器
  - 更现代的卡片设计
  - 优化饮品选择按钮样式
  - 改进提醒设置弹窗 UI

### 技术改进
- 提醒数量从 16 个增加到 24 个，支持更长时间段
- 使用 `SingleTickerProviderStateMixin` 实现波浪动画

---

## 2024-12-21 管理员后台系统

### 新增功能
- **管理员后台 (Vue 3 + Element Plus)**
  - 管理员登录（账号: nagenanren / 密码: nagenanren123）
  - 用户列表查看（总用户数统计）
  - 添加用户功能
  - 重置用户密码功能
  - 不允许查看用户计划和消费记录

### 后端更新
- 新增 `backend/internal/handlers/admin.go` - 管理员 API
- 新增 `backend/internal/middleware/admin.go` - 管理员认证中间件
- 添加 CORS 支持 (`github.com/gin-contrib/cors`)
- 管理员路由: `/api/admin/login`, `/api/admin/users`

### 部署配置
- 前端部署: OpenResty 端口 3000，目录 `/www/sites/120.27.115.89/index`
- 后端部署: Docker 容器，端口 8080
- 需要配置 `try_files $uri $uri/ /index.html;` 解决 SPA 刷新 404

### 1Panel 容器编排
```yaml
version: '3.8'

services:
  backend:
    image: golang:1.21-alpine
    container_name: daily_planner_backend
    restart: always
    working_dir: /app
    environment:
      GOPROXY: https://goproxy.cn,direct
      DB_HOST: 127.0.0.1
      DB_PORT: 3306
      DB_USER: planner
      DB_PASSWORD: nagenanren123
      DB_NAME: daily_planner
      JWT_SECRET: your-super-secret-jwt-key-2024
      SERVER_PORT: 8080
    network_mode: host
    command: sh -c "cd /app && go mod tidy && go run ./cmd/main.go"
    volumes:
      - /opt/flutter_app/backend:/app
```

### OpenResty 配置 (宝塔面板)
```nginx
server {
    listen 3000;
    server_name 120.27.115.89;
    
    index index.html;
    root /www/sites/120.27.115.89/index;
    
    # SPA 路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    access_log /www/sites/120.27.115.89/log/access.log main;
    error_log /www/sites/120.27.115.89/log/error.log;
}
```

---

## 历史版本

### v1.4.0 主题设置 & 修改密码
- 主题切换（浅色/深色/跟随系统）
- 修改密码功能
- 美化开关组件

### v1.3.0 用户资料系统
- 用户名、昵称、头像
- 注册流程优化
- 16 个 emoji 头像选择

### v1.2.0 喝水记录
- 8 种饮品类型
- 每日 2000ml 目标
- 滑动删除记录

### v1.1.0 基础功能
- 每日计划
- 消费记录
- 提醒功能
