# 实现计划

- [x] 1. 后端管理员 API 开发




  - [ ] 1.1 创建管理员处理器文件 `backend/internal/handlers/admin.go`
    - 实现 AdminLogin 函数（硬编码验证 nagenanren/nagenanren123）
    - 实现 GetUsers 函数（返回用户列表，不含敏感数据）
    - 实现 CreateUser 函数（管理员创建用户）


    - 实现 ResetUserPassword 函数（重置用户密码）
    - _需求: 1.2, 1.3, 2.1, 2.3, 3.2, 4.2_
  - [ ] 1.2 添加管理员路由到 `backend/cmd/main.go`
    - 添加 /api/admin/login 路由（公开）






    - 添加 /api/admin/users 路由组（需要管理员 token）

    - _需求: 1.4_
  - [ ] 1.3 创建管理员中间件 `backend/internal/middleware/admin.go`
    - 实现管理员 token 验证
    - _需求: 1.4_





- [ ] 2. 前端项目初始化
  - [ ] 2.1 创建 Vue 3 项目 `admin-dashboard`
    - 使用 Vite 创建项目

    - 安装 Element Plus、Vue Router、Axios、Pinia
    - _需求: 1.1_
  - [x] 2.2 配置项目基础结构

    - 配置 Element Plus
    - 配置路由




    - 配置 API 服务
    - _需求: 1.1_



- [ ] 3. 前端登录功能
  - [ ] 3.1 创建登录页面 `src/views/LoginView.vue`
    - 用户名输入框
    - 密码输入框

    - 登录按钮
    - 错误提示
    - _需求: 1.1, 1.2, 1.3_
  - [x] 3.2 实现登录 API 和状态管理


    - 创建 auth store
    - 实现登录/退出逻辑
    - _需求: 1.2, 1.5_




  - [ ] 3.3 实现路由守卫
    - 未登录重定向到登录页
    - _需求: 1.4_



- [ ] 4. 前端仪表盘和用户管理
  - [ ] 4.1 创建布局组件 `src/layouts/AdminLayout.vue`
    - 侧边栏
    - 顶部导航
    - 退出登录按钮
    - _需求: 1.5_
  - [ ] 4.2 创建仪表盘页面 `src/views/DashboardView.vue`
    - 统计卡片（总用户数）
    - 用户列表表格
    - 添加用户按钮
    - 重置密码按钮
    - _需求: 2.1, 2.3, 3.1, 4.1_
  - [ ] 4.3 实现用户管理功能
    - 添加用户对话框
    - 重置密码对话框
    - 表单验证
    - _需求: 3.2, 3.3, 3.4, 3.5, 4.2, 4.3, 4.4, 4.5_

- [ ] 5. 检查点 - 确保所有功能正常
  - 确保所有测试通过，如有问题请询问用户。

- [ ] 6. 部署配置
  - [ ] 6.1 更新 docker-compose.yml
    - 添加前端服务配置
    - _需求: 部署_
  - [ ] 6.2 创建前端 Dockerfile
    - 构建生产版本
    - 使用 nginx 服务
    - _需求: 部署_

