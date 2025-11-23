<template>
  <Layout>
    <div class="user-management-container">
      <h1>用户管理</h1>
      <div class="user-management-content">
        <!-- 操作栏 -->
        <div class="operation-bar">
          <el-button type="primary" @click="fetchAllUsers">
            <el-icon><Refresh /></el-icon>
            刷新用户列表
          </el-button>
        </div>
        
        <!-- 用户列表表格 -->
        <el-card class="user-table-card">
          <el-table
            v-loading="loading"
            :data="paginatedUsers"
            style="width: 100%"
            stripe
          >
            <el-table-column prop="id" label="用户ID" width="80" />
            <el-table-column prop="username" label="用户名" width="120" />
            <el-table-column prop="nickname" label="昵称" width="120" />
            <el-table-column prop="email" label="邮箱" />
            <el-table-column prop="phone" label="手机号" width="120" />
            <el-table-column prop="role" label="角色" width="80">
              <template #default="scope">
                <el-tag :type="getRoleType(scope.row.role)">
                  {{ getRoleText(scope.row.role) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="scope">
                <el-button size="small" type="primary">编辑</el-button>
                <el-button size="small" type="danger">禁用</el-button>
              </template>
            </el-table-column>
          </el-table>
          
          <!-- 分页 -->
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="pagination.currentPage"
              v-model:page-size="pagination.pageSize"
              :page-sizes="[5, 10, 20, 50]"
              layout="total, sizes, prev, pager, next, jumper"
              :total="pagination.total"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
            />
          </div>
        </el-card>
      </div>
    </div>
  </Layout>
</template>

<script setup>
import { onMounted, ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import Layout from '../components/Layout.vue'
import { useUserStore } from '../stores/userStore'
import userService from '../api/user'

const userStore = useUserStore()

// 所有用户列表数据
const allUsers = ref([])
// 加载状态
const loading = ref(false)
// 分页数据
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

// 确保用户信息已初始化
onMounted(async () => {
  if (!userStore.initialized) {
    await userStore.initializeUserInfo()
  }
  
  // 获取所有用户信息
  await fetchAllUsers()
})

// 获取所有用户信息
const fetchAllUsers = async () => {
  loading.value = true
  try {
    const users = await userService.getAllUsers()
    allUsers.value = Array.isArray(users) ? users : []
    pagination.total = allUsers.value.length
    console.log('获取到的用户列表:', allUsers.value)
  } catch (error) {
    console.error('获取用户列表失败:', error)
    ElMessage.error('获取用户列表失败，请稍后重试')
    allUsers.value = []
  } finally {
    loading.value = false
  }
}

// 计算当前页显示的用户
const paginatedUsers = computed(() => {
  const start = (pagination.currentPage - 1) * pagination.pageSize
  const end = start + pagination.pageSize
  return allUsers.value.slice(start, end)
})

// 处理页码变化
const handleCurrentChange = (current) => {
  pagination.currentPage = current
}

// 处理页面大小变化
const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.currentPage = 1 // 重置为第一页
}

// 获取角色文本
const getRoleText = (role) => {
  const roleMap = {
    'admin': '管理员',
    'user': '普通用户'
  }
  return roleMap[role] || '未知角色'
}

// 获取角色标签类型
const getRoleType = (role) => {
  const typeMap = {
    'admin': 'danger',
    'user': 'success'
  }
  return typeMap[role] || 'info'
}
</script>

<style scoped>
.user-management-container {
  padding: 20px;
  min-height: calc(100vh - 64px);
}

.user-management-content {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.user-management-container h1 {
  color: #409eff;
  margin-bottom: 20px;
  font-size: 24px;
}

.operation-bar {
  margin-bottom: 20px;
}

.user-table-card {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-management-container {
    padding: 10px;
  }
  
  .user-management-content {
    padding: 15px;
  }
  
  .pagination-container {
    justify-content: center;
  }
}
</style>