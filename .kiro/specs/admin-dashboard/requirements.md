# 管理后台需求文档

## 简介

为每日计划 App 创建一个基于 Vue 3 的管理后台系统，允许管理员管理用户账户。管理员账户是固定的，不允许注册新管理员。管理员可以查看用户统计、重置用户密码、添加新用户，但不能查看用户的私人数据（计划和消费记录）。

## 术语表

- **Admin_Dashboard**: 管理后台系统
- **Administrator**: 管理员用户，固定账户 nagenanren
- **User**: 普通 App 用户
- **User_Management**: 用户管理功能模块

## 需求

### 需求 1

**用户故事:** 作为管理员，我想要登录管理后台，以便管理用户账户。

#### 验收标准

1. WHEN 管理员访问后台登录页面 THEN Admin_Dashboard SHALL 显示用户名和密码输入框
2. WHEN 管理员输入正确的凭据（nagenanren/nagenanren123）THEN Admin_Dashboard SHALL 验证成功并跳转到仪表盘
3. WHEN 管理员输入错误的凭据 THEN Admin_Dashboard SHALL 显示错误提示并保持在登录页面
4. WHEN 未登录用户访问后台页面 THEN Admin_Dashboard SHALL 重定向到登录页面
5. WHEN 管理员点击退出登录 THEN Admin_Dashboard SHALL 清除登录状态并返回登录页面

### 需求 2

**用户故事:** 作为管理员，我想要查看用户统计信息，以便了解系统使用情况。

#### 验收标准

1. WHEN 管理员登录成功后 THEN Admin_Dashboard SHALL 在仪表盘显示总用户数
2. WHEN 有新用户注册 THEN Admin_Dashboard SHALL 在刷新后更新总用户数统计
3. WHEN 管理员查看仪表盘 THEN Admin_Dashboard SHALL 显示用户列表（用户名、手机号、昵称、注册时间）

### 需求 3

**用户故事:** 作为管理员，我想要重置用户密码，以便帮助忘记密码的用户。

#### 验收标准

1. WHEN 管理员在用户列表中选择重置密码 THEN Admin_Dashboard SHALL 显示密码重置对话框
2. WHEN 管理员输入新密码并确认 THEN Admin_Dashboard SHALL 调用后端 API 更新用户密码
3. WHEN 密码重置成功 THEN Admin_Dashboard SHALL 显示成功提示
4. WHEN 密码重置失败 THEN Admin_Dashboard SHALL 显示错误原因
5. WHEN 管理员输入的新密码少于6位 THEN Admin_Dashboard SHALL 阻止提交并显示验证错误

### 需求 4

**用户故事:** 作为管理员，我想要添加新用户，以便为用户创建账户。

#### 验收标准

1. WHEN 管理员点击添加用户按钮 THEN Admin_Dashboard SHALL 显示用户创建表单
2. WHEN 管理员填写用户名、手机号、密码并提交 THEN Admin_Dashboard SHALL 调用后端 API 创建用户
3. WHEN 用户创建成功 THEN Admin_Dashboard SHALL 显示成功提示并刷新用户列表
4. WHEN 用户名或手机号已存在 THEN Admin_Dashboard SHALL 显示相应错误提示
5. WHEN 表单验证失败（用户名少于3位、密码少于6位）THEN Admin_Dashboard SHALL 阻止提交并显示验证错误

### 需求 5

**用户故事:** 作为系统，我需要保护用户隐私，以便用户数据安全。

#### 验收标准

1. WHILE 管理员使用后台 THEN Admin_Dashboard SHALL 不显示任何用户的计划数据
2. WHILE 管理员使用后台 THEN Admin_Dashboard SHALL 不显示任何用户的消费记录数据
3. WHILE 管理员使用后台 THEN Admin_Dashboard SHALL 不显示任何用户的喝水记录数据
4. WHEN 后端 API 返回用户数据 THEN Admin_Dashboard SHALL 仅显示基本信息（用户名、手机号、昵称、头像、注册时间）

### 需求 6

**用户故事:** 作为系统，我需要限制管理员注册，以便保证系统安全。

#### 验收标准

1. WHEN 任何人尝试注册管理员账户 THEN Admin_Dashboard SHALL 不提供注册功能
2. WHEN 后端收到管理员创建请求 THEN 后端 SHALL 拒绝该请求
3. WHILE 系统运行 THEN Admin_Dashboard SHALL 仅允许固定管理员账户（nagenanren）登录

