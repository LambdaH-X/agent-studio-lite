<template>
  <div class="test-role-container">
    <h1>角色测试工具</h1>
    
    <el-card class="role-card">
      <template #header>
        <div class="card-header">
          <span>当前用户角色</span>
        </div>
      </template>
      
      <div class="role-display">
        <el-tag :type="currentRole === 'admin' ? 'success' : 'info'">{{ currentRole === 'admin' ? '管理员' : '普通用户' }}</el-tag>
      </div>
    </el-card>
    
    <el-card class="action-card">
      <template #header>
        <div class="card-header">
          <span>切换用户角色</span>
        </div>
      </template>
      
      <div class="action-buttons">
        <el-button type="primary" @click="setRole('admin')">设置为管理员</el-button>
        <el-button type="info" @click="setRole('user')">设置为普通用户</el-button>
        <el-button type="warning" @click="clearRole">清除角色信息</el-button>
      </div>
    </el-card>
    
    <el-card class="test-card">
      <template #header>
        <div class="card-header">
          <span>功能测试</span>
        </div>
      </template>
      
      <div class="test-links">
        <el-link type="primary" href="/home">前往首页（检查侧边栏）</el-link>
        <el-link v-if="currentRole === 'admin'" type="success" href="/admin">前往用户管理（管理员页面）</el-link>
        <el-link v-else type="danger" href="/admin">尝试访问用户管理（应显示403）</el-link>
      </div>
    </el-card>
    
    <el-card class="instructions-card">
      <template #header>
        <div class="card-header">
          <span>测试说明</span>
        </div>
      </template>
      
      <div class="instructions">
        <h3>测试步骤：</h3>
        <ol>
          <li>先设置为普通用户，访问首页，确认侧边栏不显示"用户管理"</li>
          <li>尝试访问/admin页面，应被重定向到403权限不足页面</li>
          <li>设置为管理员，刷新页面，确认侧边栏显示"用户管理"</li>
          <li>访问/admin页面，应能正常访问</li>
        </ol>
        <p class="note">注意：切换角色后需要刷新页面才能完全生效</p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

// 计算当前用户角色
const currentRole = computed(() => {
  return localStorage.getItem('userRole') || 'user'
})

// 设置用户角色
const setRole = (role) => {
  localStorage.setItem('userRole', role)
  // 重新加载页面以应用新角色
  ElMessage.success(`已设置为${role === 'admin' ? '管理员' : '普通用户'}角色，即将刷新页面...`)
  setTimeout(() => {
    window.location.reload()
  }, 1000)
}

// 清除角色信息
const clearRole = () => {
  localStorage.removeItem('userRole')
  ElMessage.success('已清除角色信息，即将刷新页面...')
  setTimeout(() => {
    window.location.reload()
  }, 1000)
}

// 组件挂载时初始化
onMounted(() => {
  // 确保用户信息已初始化
  console.log('当前角色:', currentRole.value)
})
</script>

<style scoped>
.test-role-container {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

h1 {
  color: #409eff;
  margin-bottom: 24px;
  text-align: center;
}

.role-card,
.action-card,
.test-card,
.instructions-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.role-display {
  text-align: center;
  padding: 20px 0;
}

.role-display .el-tag {
  font-size: 24px;
  padding: 10px 20px;
}

.action-buttons {
  display: flex;
  gap: 16px;
  justify-content: center;
  padding: 20px 0;
}

.test-links {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 20px 0;
}

.test-links .el-link {
  font-size: 16px;
  padding: 10px 0;
}

.instructions {
  padding: 20px 0;
}

.instructions h3 {
  color: #409eff;
  margin-bottom: 16px;
}

.instructions ol {
  padding-left: 24px;
  margin-bottom: 16px;
}

.instructions li {
  margin-bottom: 8px;
  line-height: 1.6;
}

.note {
  color: #909399;
  font-size: 14px;
  font-style: italic;
}

@media (max-width: 768px) {
  .test-role-container {
    padding: 16px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .role-display .el-tag {
    font-size: 20px;
  }
}
</style>