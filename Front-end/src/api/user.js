import axios from 'axios'

/**
 * 用户相关API服务
 */
const userService = {
  /**
   * 获取用户信息
   * @returns {Promise} 用户信息Promise
   */
  getUserInfo() {
    return axios.get('/api/user/info')
      .then(response => {
        console.log('API响应原始数据:', response);
        
        // 处理响应数据，考虑不同的响应格式
        if (response && response.data) {
          // 后端可能直接返回用户信息或包装在data中
          const userData = response.data.code === 200 ? response.data.data : response.data;
          console.log('解析后的用户数据:', userData);
          return userData;
        }
        return Promise.reject(new Error('响应数据格式不正确'))
      })
      .catch(error => {
        console.error('获取用户信息失败:', error);
        // 这里应该抛出错误，让调用者处理，而不是返回默认数据
        // 这样可以让userStore决定如何处理错误情况
        throw error;
      })
  },

  /**
   * 登录
   * @param {Object} loginData - 登录信息
   * @param {string} loginData.username - 用户名
   * @param {string} loginData.password - 密码
   * @returns {Promise} 登录结果Promise
   */
  login(loginData) {
    return axios.post('/api/user/login', loginData)
  },

  /**
   * 登出
   * @returns {Promise} 登出结果Promise
   */
  logout() {
    return axios.post('/api/user/logout')
  },

  /**
   * 获取所有用户信息（需要管理员权限）
   * @returns {Promise} 所有用户信息Promise
   */
  getAllUsers() {
    return axios.get('/api/user/all')
      .then(response => {
        console.log('获取所有用户信息响应:', response);
        // 处理响应数据，考虑不同的响应格式
        if (response && response.data) {
          const userData = response.data.code === 200 ? response.data.data : response.data;
          console.log('解析后的所有用户数据:', userData);
          return userData;
        }
        return Promise.reject(new Error('响应数据格式不正确'))
      })
      .catch(error => {
        console.error('获取所有用户信息失败:', error);
        throw error;
      })
  }
}

export default userService