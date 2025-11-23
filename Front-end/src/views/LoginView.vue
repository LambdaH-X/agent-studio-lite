<template>
  <div class="login-container">
    <div class="login-background">
      <div class="login-shape login-shape-1"></div>
      <div class="login-shape login-shape-2"></div>
      <div class="login-shape login-shape-3"></div>
    </div>
    <div class="login-content">
      <el-card class="login-card" shadow="hover">
        <template #header>
          <div class="login-header">
            <div class="logo-container">
              <div class="logo-icon">🤖</div>
            </div>
            <h2>Agent Studio Lite</h2>
            <p>登录您的账户</p>
          </div>
        </template>
        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          label-width="80px"
          class="login-form"
        >
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              prefix-icon="User"
              autocomplete="off"
              class="custom-input"
            ></el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              prefix-icon="Lock"
              show-password
              autocomplete="off"
              class="custom-input"
            ></el-input>
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              @click="handleLogin"
              :loading="loading"
              class="login-btn"
            >
              登录
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { useUserStore } from '../stores/userStore'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: 'user',
  password: '123'
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    // 调用登录接口，使用正确的API路径
    const response = await axios.post('/api/user/login', {
      username: loginForm.username,
      password: loginForm.password
    })
    
    // 从响应中获取数据
    const result = response?.data || {}
    
    // 检查响应结果 - 后端返回格式可能是直接返回token在data中
    console.log('响应数据结构:', result)
    // 提取用户角色，默认为普通用户
    const userRole = result.role || result.data?.role || 'user';
    const username = result.username || result.data?.username || loginForm.username;
    
    // 保存完整的认证信息到localStorage
    localStorage.setItem('username', username)
    localStorage.setItem('userRole', userRole)
    
    if (result.token || (result.code === 200 && (result.data?.token || result.data?.data?.token))) {
      // 存储token
      const token = result.token || result.data?.token || result.data?.data?.token;
      localStorage.setItem('token', token);
      console.log('Token已存储:', token);
      
      // 重置store的初始化状态
      userStore.initialized = false;
      
      // 优化：先确保从登录响应中提取到正确的角色信息
      // 检查响应中是否直接包含role字段
      const extractedRole = result.role || result.data?.role || result.data?.data?.role || 'user';
      console.log('从登录响应提取的角色:', extractedRole);
      
      // 立即调用initializeUserInfo获取最新的用户信息
      try {
        await userStore.initializeUserInfo();
        console.log('登录后获取的用户信息:', userStore.userInfo);
        
        // 确保角色信息正确更新
        if (extractedRole && userStore.userInfo) {
          userStore.userInfo.role = extractedRole;
          userStore.role = extractedRole;
          localStorage.setItem('userRole', extractedRole);
        }
      } catch (infoError) {
        console.error('登录后获取用户信息失败:', infoError);
        // 即使获取失败，也设置基本信息，优先使用从登录响应提取的角色
        userStore.updateUserInfo({
          username: username,
          nickname: username || '用户',
          role: extractedRole
        });
        userStore.role = extractedRole;
        localStorage.setItem('userRole', extractedRole);
      }
      
      ElMessage.success(result.message || '登录成功！')
      console.log('登录成功，用户信息:', { username, role: userRole });
      
      // 登录成功后跳转到首页
      router.push('/home');
    } else {
      ElMessage.error(result?.message || '登录失败，请检查用户名和密码')
    }
  } catch (error) {
    // 详细的错误日志记录
    console.error('登录错误详情:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      config: error.config
    })
    
    // 区分不同类型的错误并显示更具体的信息
    if (error.name === 'Error') {
      // 表单验证错误
      return
    }
    
    if (error.response) {
      // 服务器返回了错误响应
      const status = error.response.status
      if (status === 500) {
        ElMessage.error('服务器内部错误，请稍后重试')
      } else if (status === 401 || status === 403) {
        ElMessage.error('用户名或密码错误')
      } else {
        ElMessage.error(`请求失败，状态码: ${status}`)
      }
    } else if (error.request) {
      // 请求已发送但未收到响应
      ElMessage.error('网络错误，请检查连接')
    } else {
      // 请求配置出错
      ElMessage.error('请求错误，请稍后重试')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  position: relative;
  overflow: hidden;
}

.login-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
}

.login-shape {
  position: absolute;
  border-radius: 50%;
  opacity: 0.6;
}

.login-shape-1 {
  width: 300px;
  height: 300px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  top: -100px;
  right: -100px;
}

.login-shape-2 {
  width: 200px;
  height: 200px;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  bottom: -50px;
  left: -50px;
}

.login-shape-3 {
  width: 150px;
  height: 150px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  top: 50%;
  left: 10%;
  transform: translateY(-50%);
}

.login-content {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 400px;
}

.login-card {
  border-radius: 12px;
  overflow: hidden;
}

.login-header {
  text-align: center;
  padding: 20px 0;
}

.logo-container {
  display: flex;
  justify-content: center;
  margin-bottom: 16px;
}

.logo-icon {
  font-size: 48px;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  color: white;
  margin: 0 auto;
}

.login-header h2 {
  margin: 8px 0;
  color: #2c3e50;
  font-size: 24px;
}

.login-header p {
  color: #606266;
  font-size: 14px;
}

.login-form {
  padding: 0 24px 24px;
}

.custom-input {
  width: 100%;
}

.login-btn {
  width: 100%;
  height: 40px;
  font-size: 16px;
  margin-top: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .login-content {
    max-width: 90%;
    margin: 0 20px;
  }
  
  .login-shape {
    transform: scale(0.7);
  }
}
</style>