<template>
  <Layout>
    <div class="settings-container">
      <div class="settings-grid">
        <!-- 个人信息模块 -->
        <el-card class="settings-card user-info-card">
          <template #header>
            <div class="card-header">
              <span class="card-title">个人信息</span>
            </div>
          </template>
          <div class="user-info-content">
            <div class="user-avatar-section">
              <div class="user-avatar">
                <img v-if="userStore.userInfo.avatar" :src="userStore.userInfo.avatar" :alt="userStore.displayName" />
                <span v-else class="avatar-placeholder">{{ getInitials(userStore.displayName) }}</span>
              </div>
            </div>
            <div class="user-details-section">
              <div class="user-detail-item">
                <label>昵称</label>
                <span class="user-detail-value">{{ userStore.userInfo.nickname || '未设置' }}</span>
              </div>
              <div class="user-detail-item">
                <label>用户名</label>
                <span class="user-detail-value">{{ userStore.userInfo.username || '未设置' }}</span>
              </div>
              <div class="user-detail-item">
                <label>邮箱</label>
                <span class="user-detail-value">{{ userStore.userInfo.email || '未设置' }}</span>
              </div>
              <div class="user-detail-item">
                <label>手机号</label>
                <span class="user-detail-value">{{ userStore.userInfo.phone || '未设置' }}</span>
              </div>
              <!-- 仅对非管理员用户显示性别和生日 -->
              <div v-if="!isAdmin" class="user-detail-item">
                <label>性别</label>
                <span class="user-detail-value">{{ userStore.genderText }}</span>
              </div>
              <div v-if="!isAdmin" class="user-detail-item">
                <label>出生日期</label>
                <span class="user-detail-value">{{ userStore.userInfo.birthdate || '未设置' }}</span>
              </div>
            </div>
          </div>
        </el-card>
        
        <!-- 智能体设置模块 -->
        <el-card class="settings-card agent-settings">
          <template #header>
            <div class="card-header">
              <span class="card-title">智能体设置</span>
            </div>
          </template>
          <div class="agent-settings-content">
            <div class="empty-state">
              <div class="empty-icon">🤖</div>
              <p class="empty-text">智能体设置功能即将推出</p>
              <p class="empty-subtext">请稍后再来查看</p>
            </div>
          </div>
        </el-card>
     </div>
    </div>
  </Layout>
</template>
<script setup>
import { onMounted, computed } from 'vue'
import Layout from '../components/Layout.vue'
import { useUserStore } from '../stores/userStore'

const userStore = useUserStore()

// 检查是否为管理员角色
const isAdmin = computed(() => {
  return userStore.userInfo && userStore.userInfo.role === 'admin'
})

// 获取用户姓名首字母
const getInitials = (name) => {
  if (!name || name === '用户') return 'U'
  return name.charAt(0).toUpperCase()
}

// 设置页面
onMounted(async () => {
  console.log('设置页面已加载')
  // 确保用户信息已初始化
  if (!userStore.initialized) {
    await userStore.initializeUserInfo()
  }
})
</script>

<style scoped>
.settings-container {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
}

.settings-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.settings-card {
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 18px;
  font-weight: 500;
  color: #303133;
}

/* 个人信息卡片样式 */
.user-info-card {
  background-color: #ffffff;
}

.user-info-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 0;
}

.user-avatar-section {
  margin-bottom: 24px;
}

.user-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  overflow: hidden;
  background-color: #409eff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  color: white;
  font-size: 36px;
  font-weight: 600;
}

.user-details-section {
  width: 100%;
  max-width: 400px;
}

.user-detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.user-detail-item:last-child {
  border-bottom: none;
}

.user-detail-item label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.user-detail-value {
  font-size: 14px;
  color: #303133;
  max-width: 60%;
  text-align: right;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 智能体设置样式 */
.agent-settings {
  background-color: #ffffff;
}

.agent-settings-content {
  padding: 24px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  text-align: center;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 8px;
}

.empty-subtext {
  color: #909399;
  font-size: 14px;
}

/* 暗色主题支持 */
:global(.dark-theme) .settings-container {
  background-color: #1a1a1a;
}

:global(.dark-theme) .settings-card {
  background-color: #2a2a2a;
  border-color: #3a3a3a;
}

:global(.dark-theme) .card-title {
  color: #ffffff;
}

:global(.dark-theme) .user-detail-item {
  border-color: #3a3a3a;
}

:global(.dark-theme) .user-detail-item label {
  color: #cccccc;
}

:global(.dark-theme) .user-detail-value {
  color: #ffffff;
}

/* 响应式设计 */
@media (min-width: 768px) {
  .settings-grid {
    grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  }
}

@media (max-width: 767px) {
  .settings-container {
    padding: 16px;
  }
  
  .user-info-content {
    padding: 16px 0;
  }
  
  .user-avatar {
    width: 80px;
    height: 80px;
  }
  
  .avatar-placeholder {
    font-size: 28px;
  }
}

/* 确保文本颜色符合要求 */
h1, h2, h3, h4, h5, h6 {
  color: #409eff;
}
</style>