<template>
  <Layout :userInfo="userStore.userInfo">
    <div class="agents-container">
      <div class="page-header">
        <h1>我的智能体</h1>
        <el-button type="primary" @click="handleCreateAgent" :icon="Plus">创建智能体</el-button>
      </div>

      <!-- 智能体列表 -->
      <el-card class="agents-card">
        <div v-if="loading" class="loading-container">
          <el-skeleton :rows="5" animated />
        </div>
        <el-table
          v-else
          :data="agents"
          style="width: 100%"
          empty-text="暂无智能体数据"
        >
          <el-table-column prop="id" label="ID" width="180" />
          <el-table-column prop="name" label="名称" min-width="150">
            <template #default="scope">
              <div class="agent-name">
                <div class="name-text">{{ scope.row.name }}</div>
                <div class="agent-desc">{{ scope.row.description || '无描述' }}</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="type" label="类型" width="100">
            <template #default="scope">
              <el-tag
                :type="getAgentTypeTag(scope.row.type)"
                effect="light"
              >
                {{ scope.row.type || '默认' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="180">
            <template #default="scope">
              {{ formatDate(scope.row.createdAt) }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag
                :type="scope.row.status === 1 ? 'success' : 'danger'"
                effect="light"
              >
                {{ scope.row.status === 1 ? '启用' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="scope">
              <el-button
                type="primary"
                size="small"
                @click="handleEditAgent(scope.row)"
                :icon="Edit"
              >
                编辑
              </el-button>
              <el-button
                type="danger"
                size="small"
                @click="handleDeleteAgent(scope.row.id, scope.row.name)"
                :icon="Delete"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div v-if="!loading && agents.length > 0" class="pagination-container">
          <el-pagination
            v-model:current-page="pagination.currentPage"
            v-model:page-size="pagination.pageSize"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="pagination.total"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>

      <!-- 创建/编辑智能体弹窗 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogType === 'create' ? '创建智能体' : '编辑智能体'"
        width="500px"
      >
        <el-form
          ref="agentFormRef"
          :model="agentForm"
          :rules="rules"
          label-width="100px"
        >
          <el-form-item label="名称" prop="name">
            <el-input
              v-model="agentForm.name"
              placeholder="请输入智能体名称"
              maxlength="50"
            />
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="agentForm.description"
              type="textarea"
              placeholder="请输入智能体描述"
              rows="3"
              maxlength="200"
            />
          </el-form-item>
          <el-form-item label="类型" prop="type">
            <el-select
              v-model="agentForm.type"
              placeholder="请选择智能体类型"
            >
              <el-option label="通用助手" value="general" />
              <el-option label="知识库助手" value="knowledge" />
              <el-option label="任务助手" value="task" />
              <el-option label="创意助手" value="creative" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-switch
              v-model="agentForm.status"
              active-value="1"
              inactive-value="0"
              active-text="启用"
              inactive-text="禁用"
            />
          </el-form-item>
          <el-form-item label="配置信息" prop="config">
            <el-input
              v-model="agentForm.config"
              type="textarea"
              placeholder="请输入JSON格式的配置信息"
              rows="4"
              maxlength="1000"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSubmit">确定</el-button>
          </span>
        </template>
      </el-dialog>
    </div>
  </Layout>
</template>

<script setup>
import { onMounted, ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit, Delete, Plus } from '@element-plus/icons-vue'
import Layout from '../components/Layout.vue'
import { useUserStore } from '../stores/userStore'
import agentService from '../api/agent'

const userStore = useUserStore()

// 响应式数据
const agents = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const dialogType = ref('create') // 'create' 或 'edit'
const currentAgentId = ref(null)
const agentFormRef = ref(null)

// 分页数据
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

// 表单数据
const agentForm = reactive({
  name: '',
  description: '',
  type: 'general',
  status: '1', // 默认启用
  config: '{}'
})

// 表单验证规则
const rules = {
  name: [
    { required: true, message: '请输入智能体名称', trigger: 'blur' },
    { min: 2, max: 50, message: '名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  description: [
    { max: 200, message: '描述不能超过 200 个字符', trigger: 'blur' }
  ],
  config: [
    {
      validator: (rule, value, callback) => {
        if (value) {
          try {
            JSON.parse(value)
            callback()
          } catch (e) {
            callback(new Error('请输入有效的JSON格式'))
          }
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 获取智能体列表
const fetchAgents = async () => {
  loading.value = true
  try {
    // 传递分页参数
    const params = {
      page: pagination.currentPage,
      pageSize: pagination.pageSize
    }
    const response = await agentService.getAgents(params)
    
    // 假设后端返回的格式为 { data: [...], total: number }
    if (response && response.data) {
      agents.value = Array.isArray(response.data) ? response.data : []
      // 使用后端返回的总数，而不是前端计算
      pagination.total = response.total || 0
    } else {
      // 兼容旧格式
      agents.value = Array.isArray(response) ? response : []
      pagination.total = agents.value.length
    }
    
    console.log('获取智能体列表成功:', agents.value)
  } catch (error) {
    console.error('获取智能体列表失败:', error)
    ElMessage.error('获取智能体列表失败，请稍后重试')
    agents.value = []
    pagination.total = 0
  } finally {
    loading.value = false
  }
}

// 创建智能体
const handleCreateAgent = () => {
  dialogType.value = 'create'
  currentAgentId.value = null
  // 重置表单
    Object.assign(agentForm, {
      name: '',
      description: '',
      type: 'general',
      status: '1', // 默认启用
      config: '{}'
    })
  if (agentFormRef.value) {
    agentFormRef.value.resetFields()
  }
  dialogVisible.value = true
}

// 编辑智能体
const handleEditAgent = async (agent) => {
  dialogType.value = 'edit'
  currentAgentId.value = agent.id
  
  try {
    // 获取智能体详情
    const detail = await agentService.getAgentById(agent.id)
    // 填充表单
    Object.assign(agentForm, {
      name: detail.name || '',
      description: detail.description || '',
      type: detail.type || 'general',
      status: String(detail.status || 1), // 转换为字符串以匹配开关组件
      config: typeof detail.config === 'string' ? detail.config : JSON.stringify(detail.config || {}, null, 2)
    })
    dialogVisible.value = true
  } catch (error) {
    console.error('获取智能体详情失败:', error)
    ElMessage.error('获取智能体详情失败，请稍后重试')
  }
}

// 删除智能体
const handleDeleteAgent = (id, name) => {
  ElMessageBox.confirm(
    `确定要删除智能体「${name}」吗？此操作不可恢复。`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  )
    .then(async () => {
      try {
        await agentService.deleteAgent(id)
        ElMessage.success('删除成功')
        // 重新获取列表
        await fetchAgents()
      } catch (error) {
        console.error('删除智能体失败:', error)
        ElMessage.error('删除失败，请稍后重试')
      }
    })
    .catch(() => {
      // 取消删除
    })
}

// 提交表单
const handleSubmit = async () => {
  if (!agentFormRef.value) return
  
  await agentFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const formData = {
          ...agentForm,
          status: parseInt(agentForm.status), // 转换为数字
          config: agentForm.config ? JSON.parse(agentForm.config) : {}
        }
        
        if (dialogType.value === 'create') {
          await agentService.createAgent(formData)
          ElMessage.success('创建成功')
        } else {
          await agentService.updateAgent(currentAgentId.value, formData)
          ElMessage.success('更新成功')
        }
        
        dialogVisible.value = false
        // 重新获取列表
        await fetchAgents()
      } catch (error) {
        console.error(`${dialogType.value === 'create' ? '创建' : '更新'}智能体失败:`, error)
        ElMessage.error(`${dialogType.value === 'create' ? '创建' : '更新'}失败，请稍后重试`)
      }
    }
  })
}

// 分页处理
const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.currentPage = 1
  // 重新获取数据
  fetchAgents()
}

const handleCurrentChange = (current) => {
  pagination.currentPage = current
  // 重新获取数据
  fetchAgents()
}

// 辅助函数：获取智能体类型标签样式
const getAgentTypeTag = (type) => {
  const typeMap = {
    'general': 'primary',
    'knowledge': 'success',
    'task': 'warning',
    'creative': 'info'
  }
  return typeMap[type] || 'default'
}

// 辅助函数：格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 初始化
onMounted(async () => {
  console.log('Agent管理页面已加载')
  // 确保用户信息已初始化
  if (!userStore.initialized) {
    await userStore.initializeUserInfo()
  }
  // 获取智能体列表
  await fetchAgents()
})
</script>

<style scoped>
.agents-container {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 64px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  color: #303133;
  font-size: 24px;
  margin: 0;
}

.agents-card {
  background-color: white;
}

.loading-container {
  padding: 20px 0;
}

.agent-name {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.name-text {
  font-weight: 500;
  color: #303133;
}

.agent-desc {
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
  max-height: 34px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .agents-container {
    padding: 10px;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .pagination-container {
    justify-content: center;
  }
}
</style>