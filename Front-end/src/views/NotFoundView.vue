<template>
  <div class="not-found-container">
    <div class="not-found-content">
      <h1>404</h1>
      <h2>页面未找到</h2>
      <p>您访问的页面不存在或已被移除</p>
      <p class="redirect-message">将在 <span class="countdown">{{ countdown }}</span> 秒后自动跳转至首页...</p>
      <button class="redirect-button" @click="redirectToHome">立即前往首页</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const countdown = ref(5)
let timer = null

// 重定向到首页
const redirectToHome = () => {
  router.push('/home')
}

// 设置倒计时
const startCountdown = () => {
  timer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(timer)
      redirectToHome()
    }
  }, 1000)
}

// 组件挂载时开始倒计时
onMounted(() => {
  startCountdown()
})

// 组件卸载时清除定时器
onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})
</script>

<style scoped>
.not-found-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f7fa;
}

.not-found-content {
  text-align: center;
  padding: 40px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
}

.not-found-content h1 {
  font-size: 8rem;
  font-weight: 700;
  margin: 0;
  color: #409eff;
  line-height: 1;
}

.not-found-content h2 {
  font-size: 2rem;
  color: #303133;
  margin: 20px 0 10px;
}

.not-found-content p {
  color: #606266;
  font-size: 1.1rem;
  margin: 10px 0;
}

.redirect-message {
  margin: 30px 0;
}

.countdown {
  font-size: 1.5rem;
  font-weight: 600;
  color: #f56c6c;
}

.redirect-button {
  background-color: #409eff;
  color: white;
  border: none;
  padding: 12px 32px;
  font-size: 1rem;
  font-weight: 500;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
  margin-top: 20px;
}

.redirect-button:hover {
  background-color: #66b1ff;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .not-found-content h1 {
    font-size: 6rem;
  }
  
  .not-found-content h2 {
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .not-found-content h1 {
    font-size: 4rem;
  }
  
  .not-found-content {
    padding: 30px 20px;
  }
}
</style>