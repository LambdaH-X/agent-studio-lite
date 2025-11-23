<template>
  <Layout :userInfo="userStore.userInfo">
    <div class="dashboard-content">
      <!-- 顶部导航栏 -->
      <header class="main-header">
        <div class="header-left">
          <h1 class="page-title">{{ pageTitle }}</h1>
        </div>
        
        <div class="header-right">
          <div class="header-actions">


          </div>
        </div>
      </header>
      
      <!-- 内容区域 -->
      <div class="content-wrapper">
        <!-- 欢迎区域 -->
        <section class="welcome-section">
          <div class="welcome-card">
            <div class="welcome-content">
              <h2>欢迎回来，{{ username }}！</h2>
              <p>今天是个工作的好日子，有什么可以帮助您的？</p>
              <el-button type="primary" class="welcome-btn">
                <el-icon><Plus /></el-icon>
                创建新任务
              </el-button>
            </div>
            <div class="welcome-illustration">
              <div class="illustration-icon">🚀</div>
            </div>
          </div>
        </section>
        
        <!-- 统计卡片 -->
        <section class="stats-section">
          <div class="stats-grid">
            <el-card class="stat-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-info">
                  <div class="stat-number">{{ taskCount }}</div>
                  <div class="stat-label">任务总数</div>
                </div>
                <div class="stat-icon task-icon">📋</div>
              </div>
              <div class="stat-trend positive">
                <el-icon><TrendCharts /></el-icon>
                <span>+12% 本周</span>
              </div>
            </el-card>
            
            <el-card class="stat-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-info">
                  <div class="stat-number">{{ completedTasks }}</div>
                  <div class="stat-label">已完成任务</div>
                </div>
                <div class="stat-icon completed-icon">✅</div>
              </div>
              <div class="stat-trend positive">
                <el-icon><TrendCharts /></el-icon>
                <span>+8% 本周</span>
              </div>
            </el-card>
            
            <el-card class="stat-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-info">
                  <div class="stat-number">{{ activeAgents }}</div>
                  <div class="stat-label">活跃Agent</div>
                </div>
                <div class="stat-icon agent-icon">🤖</div>
              </div>
              <div class="stat-trend positive">
                <el-icon><TrendCharts /></el-icon>
                <span>+5% 本周</span>
              </div>
            </el-card>
            
            <el-card class="stat-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-info">
                  <div class="stat-number">{{ avgCompletion }}</div>
                  <div class="stat-label">平均完成率</div>
                </div>
                <div class="stat-icon efficiency-icon">📈</div>
              </div>
              <div class="stat-trend negative">
                <el-icon><TrendCharts /></el-icon>
                <span>-2% 本周</span>
              </div>
            </el-card>
          </div>
        </section>
        
        <!-- 最近活动和性能分析 -->
        <section class="dashboard-section">
          <div class="dashboard-grid">
            <!-- 最近活动 -->
            <el-card class="dashboard-card" shadow="hover">
              <template #header>
                <div class="card-header">
                  <h3>最近活动</h3>
                  <el-button type="text" size="small">查看全部</el-button>
                </div>
              </template>
              <div class="activity-list">
                <div class="activity-item" v-for="activity in recentActivities" :key="activity.id">
                  <div class="activity-icon">{{ activity.icon }}</div>
                  <div class="activity-content">
                    <div class="activity-title">{{ activity.title }}</div>
                    <div class="activity-time">{{ activity.time }}</div>
                  </div>
                  <el-button type="text" size="small" class="activity-action">
                    查看
                  </el-button>
                </div>
              </div>
            </el-card>
            
            <!-- 性能分析 -->
            <el-card class="dashboard-card" shadow="hover">
              <template #header>
                <div class="card-header">
                  <h3>性能分析</h3>
                  <el-select v-model="performanceRange" size="small" class="range-select">
                    <el-option label="今日" value="day"></el-option>
                    <el-option label="本周" value="week"></el-option>
                    <el-option label="本月" value="month"></el-option>
                  </el-select>
                </div>
              </template>
              <div class="performance-chart">
                <!-- 这里可以放置图表组件，目前使用占位符 -->
                <div class="chart-placeholder">
                  <div class="chart-icon">📊</div>
                  <p>性能图表区域</p>
                </div>
              </div>
            </el-card>
          </div>
        </section>
      </div>
    </div>
  </Layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import Layout from '../components/Layout.vue'
import { useUserStore } from '../stores/userStore'

const router = useRouter()
const userStore = useUserStore()

// 性能范围选择
const performanceRange = ref('week')

// 用户信息
const username = ref('用户')

// 统计数据
const taskCount = ref(42)
const completedTasks = ref(36)
const activeAgents = ref(5)
const avgCompletion = ref('85%')

// 模拟最近活动数据
const recentActivities = ref([
  {
    id: 1,
    icon: '✅',
    title: '任务 "客户调研" 已完成',
    time: '10分钟前'
  },
  {
    id: 2,
    icon: '🤖',
    title: 'Agent "数据分析助手" 已启动',
    time: '30分钟前'
  },
  {
    id: 3,
    icon: '📋',
    title: '新任务 "项目规划" 已创建',
    time: '2小时前'
  },
  {
    id: 4,
    icon: '💬',
    title: '收到新的对话消息',
    time: '昨天'
  }
])

// 页面加载时执行
onMounted(async () => {
  // 从localStorage获取用户信息作为初始值
  const savedUsername = localStorage.getItem('username')
  if (savedUsername) {
    username.value = savedUsername
  }
  
  // 初始化用户信息（从API获取）
  await userStore.initializeUserInfo()
  
  // 优先使用昵称，其次使用用户名
  if (userStore.userInfo && userStore.userInfo.nickname) {
    username.value = userStore.userInfo.nickname
  } else if (userStore.displayName && userStore.displayName !== '用户') {
    username.value = userStore.displayName
  }
})
</script>

<style scoped>
/* 主容器 */
.dashboard-content {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px); /* 减去顶部导航栏高度 */
}

/* 标题样式 - 顶部导航栏由Layout组件提供 */

/* 内容区域直接使用dashboard-content作为包装器 */

/* 欢迎区域 */
.welcome-section {
  margin-bottom: 24px;
}

.welcome-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: #ffffff;
}

.welcome-content h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
}

.welcome-content p {
  margin: 0 0 16px 0;
  opacity: 0.9;
  font-size: 14px;
}

.welcome-btn {
  background-color: #ffffff;
  color: #667eea;
  border: none;
  transition: all 0.3s ease;
}

.welcome-btn:hover {
  background-color: rgba(255, 255, 255, 0.9);
  color: #764ba2;
}

.welcome-illustration {
  margin-left: 40px;
}

.illustration-icon {
  font-size: 64px;
  opacity: 0.8;
}

/* 统计卡片 */
.stats-section {
  margin-bottom: 24px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.stat-card {
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.task-icon {
  background-color: #ecf5ff;
  color: #409eff;
}

.completed-icon {
  background-color: #f0f9ff;
  color: #67c23a;
}

.agent-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.efficiency-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.stat-trend.positive {
  color: #67c23a;
}

.stat-trend.negative {
  color: #f56c6c;
}

/* 仪表盘区域 */
.dashboard-section {
  margin-bottom: 24px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.dashboard-card {
  height: 100%;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.range-select {
  width: 120px;
}

/* 活动列表 */
.activity-list {
  max-height: 300px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  background-color: #f5f7fa;
}

.activity-content {
  flex: 1;
}

.activity-title {
  font-size: 14px;
  color: #2c3e50;
  margin-bottom: 4px;
}

.activity-time {
  font-size: 12px;
  color: #909399;
}

.activity-action {
  color: #409eff;
}

/* 图表占位符 */
.performance-chart {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .dashboard-content {
    padding: 16px;
  }
  
  .welcome-card {
    flex-direction: column;
    text-align: center;
  }
  
  .welcome-illustration {
    margin-left: 0;
    margin-top: 20px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
}

/* 滚动条样式 */
.activity-list::-webkit-scrollbar {
  width: 4px;
}

.activity-list::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.activity-list::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 2px;
}

.activity-list::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>