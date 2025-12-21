import axios from 'axios'
import { ElMessage } from 'element-plus'

const instance = axios.create({
  baseURL: 'http://120.27.115.89:8080/api/admin',
  timeout: 10000
})

// 请求拦截器
instance.interceptors.request.use(
  config => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// 响应拦截器
instance.interceptors.response.use(
  response => response.data,
  error => {
    const message = error.response?.data?.error || '网络错误'
    
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_info')
      window.location.href = '/login'
    } else {
      ElMessage.error(message)
    }
    
    return Promise.reject(error)
  }
)

export default {
  // 登录
  login(username, password) {
    return instance.post('/login', { username, password })
  },

  // 获取用户列表
  getUsers() {
    return instance.get('/users')
  },

  // 创建用户
  createUser(data) {
    return instance.post('/users', data)
  },

  // 重置密码
  resetPassword(userId, newPassword) {
    return instance.put(`/users/${userId}/password`, { new_password: newPassword })
  }
}
