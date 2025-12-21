import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../api'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('admin_token') || '')
  const admin = ref(JSON.parse(localStorage.getItem('admin_info') || 'null'))

  const isLoggedIn = computed(() => !!token.value)

  async function login(username, password) {
    const response = await api.login(username, password)
    token.value = response.token
    admin.value = response.admin
    localStorage.setItem('admin_token', response.token)
    localStorage.setItem('admin_info', JSON.stringify(response.admin))
    return response
  }

  function logout() {
    token.value = ''
    admin.value = null
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_info')
  }

  return {
    token,
    admin,
    isLoggedIn,
    login,
    logout
  }
})
