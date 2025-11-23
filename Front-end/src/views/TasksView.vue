<template>
  <Layout :userInfo="userStore.userInfo">
    <div class="tasks-container">
      <el-card class="feature-card">
        <h1>任务管理功能正在实现中</h1>
      </el-card>
    </div>
  </Layout>
</template>

<script setup>
import { onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import { useUserStore } from '../stores/userStore'

const userStore = useUserStore()

// 任务管理页面
onMounted(async () => {
  console.log('任务管理页面已加载')
  // 确保用户信息已初始化
  if (!userStore.initialized) {
    await userStore.initializeUserInfo()
  }
})
</script>

<style scoped>
.tasks-container {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
  display: flex;
  justify-content: center;
  align-items: center;
}

.feature-card {
  width: 100%;
  max-width: 600px;
  text-align: center;
  padding: 48px 24px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

h1 {
  color: #409eff;
  font-size: 24px;
  font-weight: 500;
  margin: 0;
}
</style>