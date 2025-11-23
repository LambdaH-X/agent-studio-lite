import { defineStore } from 'pinia'
import userService from '../api/user'

/**
 * 用户状态管理Store
 */
export const useUserStore = defineStore('user', {
  state: () => ({
    /** 用户信息对象 */
    userInfo: {
      nickname: '',
      username: '',
      role: localStorage.getItem('userRole') || 'user',
      avatar: '',
      email: '',
      phone: '',
      gender: null,
      birthdate: ''
    },
    /** 用户角色 */
    role: localStorage.getItem('userRole') || 'user',
    /** 是否正在加载 */
    loading: false,
    /** 错误信息 */
    error: null,
    /** 是否已初始化 */
    initialized: false
  }),

  getters: {
    /**
     * 获取用户显示名称（优先使用昵称）
     */
    displayName: (state) => {
      return state.userInfo.nickname || state.userInfo.username || '用户'
    },

    /**
     * 获取用户头像或占位符文本
     */
    avatarOrInitials: (state) => {
      if (state.userInfo.avatar) {
        return state.userInfo.avatar
      }
      // 返回用户名首字母作为占位符
      const name = state.displayName
      return name.charAt(0).toUpperCase()
    },
    
    /**
     * 获取性别显示文本
     */
    genderText: (state) => {
      if (state.userInfo.gender === null || state.userInfo.gender === undefined) {
        return '未设置'
      }
      return state.userInfo.gender === 1 ? '男' : '女'
    },
    
    /**
     * 检查用户是否是管理员
     */
    isAdmin: (state) => {
      return state.role === 'admin'
    }
  },

  actions: {
    /**
     * 初始化用户信息
     */
    async initializeUserInfo() {
      // 无论是否已经初始化，都尝试更新用户信息，确保数据的最新性
      this.loading = true
      this.error = null
      
      try {
        // 首先从localStorage获取已有的信息，确保即使API调用失败也有基础数据
        const storedRole = localStorage.getItem('userRole') || 'user'
        const storedUsername = localStorage.getItem('username') || 'user'
        
        // 立即更新状态中的角色信息
        this.role = storedRole
        
        try {
          // 尝试从API获取最新用户信息
          const response = await userService.getUserInfo()
          
          console.log('从API获取的用户信息:', response)
          
          // 确保response是对象
          if (response && typeof response === 'object') {
            // 处理各种可能的响应格式
            const data = response.data || response;
            
            // 提取角色信息，优先从API响应获取
            const roleFromApi = data.role || response.role || storedRole;
            console.log('从API提取的角色:', roleFromApi);
            
            // 构建完整的用户信息对象，确保包含role字段
            const userInfo = {
              nickname: data.nickname || data.username || storedUsername,
              username: data.username || storedUsername,
              role: roleFromApi,
              avatar: data.avatar || '',
              email: data.email || '',
              phone: data.phone || '',
              gender: data.gender !== undefined ? data.gender : null,
              birthdate: data.birthdate || ''
            }
            
            // 更新用户信息
            this.userInfo = userInfo
            
            // 保存用户角色到状态和localStorage
            this.role = roleFromApi
            localStorage.setItem('userRole', roleFromApi)
            console.log('用户角色已更新:', roleFromApi)
            
            // 保存用户名到localStorage
            const usernameToSave = response.username || storedUsername
            localStorage.setItem('username', usernameToSave)
          }
        } catch (apiError) {
          // API调用失败，使用localStorage中的数据
          console.log('API调用失败，使用本地存储的数据')
          
          // 设置用户信息，优先使用localStorage中的数据，确保包含role字段
          this.userInfo = {
            nickname: storedUsername,
            username: storedUsername,
            role: storedRole,
            avatar: '',
            email: '',
            phone: '',
            gender: null,
            birthdate: ''
          }
        }
        
        // 无论如何都标记为已初始化
        this.initialized = true
      } catch (error) {
        // 最终错误处理
        console.error('初始化用户信息失败:', error)
        
        // 确保即使出错也有基本的用户信息
        const savedUsername = localStorage.getItem('username') || 'user'
        const savedRole = localStorage.getItem('userRole') || 'user'
        
        this.userInfo = {
          nickname: savedUsername,
          username: savedUsername,
          role: savedRole,
          avatar: '',
          email: '',
          phone: '',
          gender: null,
          birthdate: ''
        }
        
        this.role = savedRole
        localStorage.setItem('userRole', savedRole)
        localStorage.setItem('username', savedUsername)
        
        this.initialized = true
      } finally {
        this.loading = false
      }
    },

    /**
     * 更新用户信息
     * @param {Object} newUserInfo - 新的用户信息
     */
    updateUserInfo(newUserInfo) {
      this.userInfo = { ...this.userInfo, ...newUserInfo }
    },

    /**
     * 清除用户信息（登出时使用）
     */
    clearUserInfo() {
      this.userInfo = {
        nickname: '',
        username: '',
        avatar: '',
        email: '',
        phone: '',
        gender: null,
        birthdate: ''
      }
      this.role = 'user'
      // 清除所有相关的本地存储，避免信息残留
      localStorage.removeItem('userRole')
      localStorage.removeItem('username')
      localStorage.removeItem('token')
      this.initialized = false
      this.error = null
    }
  }
})