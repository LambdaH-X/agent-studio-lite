<template>
  <div class="forbidden-container">
    <div class="forbidden-content">
      <h1>403</h1>
      <h2>权限不足</h2>
      <p>抱歉，您没有权限访问此页面</p>
      <p>请联系管理员获取相应权限</p>
      <button class="back-button" @click="goToHome">返回首页</button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

// 返回首页
const goToHome = () => {
  router.push('/home')
}
</script>

<style scoped>
.forbidden-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f7fa;
}

.forbidden-content {
  text-align: center;
  padding: 40px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
}

.forbidden-content h1 {
  font-size: 8rem;
  font-weight: 700;
  margin: 0;
  color: #f56c6c;
  line-height: 1;
}

.forbidden-content h2 {
  font-size: 2rem;
  color: #303133;
  margin: 20px 0 10px;
}

.forbidden-content p {
  color: #606266;
  font-size: 1.1rem;
  margin: 10px 0;
}

.back-button {
  background-color: #409eff;
  color: white;
  border: none;
  padding: 12px 32px;
  font-size: 1rem;
  font-weight: 500;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s;
  margin-top: 30px;
}

.back-button:hover {
  background-color: #66b1ff;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .forbidden-content h1 {
    font-size: 6rem;
  }
  
  .forbidden-content h2 {
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .forbidden-content h1 {
    font-size: 4rem;
  }
  
  .forbidden-content {
    padding: 30px 20px;
  }
}
</style>