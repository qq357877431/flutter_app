# 管理后台设计文档

## 概述

管理后台是一个基于 Vue 3 的单页应用，用于管理每日计划 App 的用户。系统采用前后端分离架构，前端使用 Vue 3 + Vite + Element Plus，后端在现有 Go 服务中添加管理员 API。

## 架构

```
┌─────────────────────────────────────────────────────────────┐
│                      管理后台前端                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   登录页面   │  │   仪表盘    │  │     用户管理        │  │
│  │  LoginView  │  │ DashboardView│ │   UserManagement   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│                           │                                  │
│                    ┌──────┴──────┐                          │
│                    │  API 服务层  │                          │
│                    │ api/admin.ts │                          │
│                    └──────┬──────┘                          │
└───────────────────────────┼─────────────────────────────────┘
                            │ HTTP
┌───────────────────────────┼─────────────────────────────────┐
│                      Go 后端服务                             │
│                    ┌──────┴──────┐                          │
│                    │ Admin Handler│                          │
│                    └──────┬──────┘                          │
│                           │                                  │
│                    ┌──────┴──────┐                          │
│                    │   MySQL DB   │                          │
│                    └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## 组件和接口

### 前端组件

#### 1. LoginView（登录页面）
- 用户名输入框
- 密码输入框
- 登录按钮
- 错误提示

#### 2. DashboardView（仪表盘）
- 统计卡片（总用户数）
- 用户列表表格
- 添加用户按钮
- 重置密码操作

#### 3. 布局组件
- AdminLayout：包含侧边栏和顶部导航
- 侧边栏菜单
- 退出登录按钮

### 后端 API

#### 管理员认证
```
POST /api/admin/login
Request: { username: string, password: string }
Response: { token: string, admin: { username: string } }
```

#### 获取用户列表
```
GET /api/admin/users
Headers: Authorization: Bearer <token>
Response: { users: User[], total: number }
```

#### 添加用户
```
POST /api/admin/users
Headers: Authorization: Bearer <token>
Request: { username: string, phone_number: string, password: string }
Response: { user: User }
```

#### 重置用户密码
```
PUT /api/admin/users/:id/password
Headers: Authorization: Bearer <token>
Request: { new_password: string }
Response: { message: string }
```

## 数据模型

### 管理员（硬编码）
```typescript
interface Admin {
  username: string  // 固定为 "nagenanren"
  password: string  // 固定为 "nagenanren123" (后端验证)
}
```

### 用户列表项
```typescript
interface UserListItem {
  id: number
  username: string
  phone_number: string
  nickname: string | null
  avatar: string | null
  created_at: string
}
```

## 正确性属性

*属性是系统在所有有效执行中应保持为真的特征或行为——本质上是关于系统应该做什么的正式声明。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

### Property 1: 管理员登录验证
*对于任何*登录请求，只有当用户名为 "nagenanren" 且密码为 "nagenanren123" 时，系统才应返回成功
**验证: 需求 1.2, 1.3**

### Property 2: 未授权访问重定向
*对于任何*未携带有效 token 的 API 请求，系统应返回 401 状态码
**验证: 需求 1.4**

### Property 3: 用户数据隐私保护
*对于任何*用户列表 API 响应，返回的用户数据不应包含 plans、expenses、water_records 字段
**验证: 需求 5.1, 5.2, 5.3, 5.4**

### Property 4: 密码长度验证
*对于任何*密码重置或用户创建请求，当密码长度小于 6 时，系统应拒绝该请求
**验证: 需求 3.5, 4.5**

### Property 5: 用户唯一性约束
*对于任何*用户创建请求，当用户名或手机号已存在时，系统应返回错误
**验证: 需求 4.4**

## 错误处理

### 前端错误处理
- 网络错误：显示 "网络连接失败，请检查网络"
- 401 错误：清除 token，重定向到登录页
- 400 错误：显示后端返回的错误信息
- 500 错误：显示 "服务器错误，请稍后重试"

### 后端错误处理
- 无效凭据：返回 401 "invalid credentials"
- 用户名已存在：返回 400 "username already exists"
- 手机号已存在：返回 400 "phone number already registered"
- 用户不存在：返回 404 "user not found"

## 测试策略

### 单元测试
- 测试登录表单验证逻辑
- 测试 API 请求函数
- 测试路由守卫逻辑

### 属性测试
- 使用 fast-check 测试密码验证属性
- 测试 token 验证属性

### 集成测试
- 测试完整登录流程
- 测试用户管理流程

