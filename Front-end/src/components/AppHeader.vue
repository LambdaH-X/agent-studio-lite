<template>
  <header class="app-header">
    <!-- 左侧区域 -->
    <div class="header-left">
      <!-- 移动端菜单按钮 -->
      <el-button 
        v-if="showMobileMenuBtn"
        class="mobile-menu-btn" 
        @click="$emit('toggle-sidebar')"
        type="text"
        size="large"
        icon="Menu"
      ></el-button>
      
      <!-- 面包屑导航 -->
      <div v-if="showBreadcrumb" class="breadcrumb-container">
        <el-breadcrumb separator="/" :routes="breadcrumbRoutes">
          <template #separator>
            <el-icon><ArrowRight /></el-icon>
          </template>
        </el-breadcrumb>
      </div>
      
      <!-- 页面标题 -->
      <h1 v-if="pageTitle" class="page-title">{{ pageTitle }}</h1>
    </div>
    
    <!-- 中间区域（可自定义内容） -->
    <div class="header-center">
      <slot name="center"></slot>
    </div>
    
    <!-- 右侧区域 -->
    <div class="header-right">
      <!-- 操作按钮 -->
      <div class="header-actions">
        <slot name="actions"></slot>
        
        <!-- 默认操作按钮 -->
        <template v-if="defaultActions.length > 0">
          <el-button 
            v-for="(action, index) in defaultActions" 
            :key="index"
            :type="action.type || 'text'"
            :size="action.size || 'large'"
            :icon="action.icon"
            :class="['action-btn', action.class]"
            :disabled="action.disabled"
            @click="action.click && action.click()"
            :title="action.title"
          >
            <template v-if="action.badge" #default>
              <span class="action-badge" :class="action.badgeClass">
                {{ action.badge }}
              </span>
            </template>
          </el-button>
        </template>
      </div>
      
      <!-- 用户信息/头像 - 使用Element Plus的下拉菜单组件 -->
      <el-dropdown 
        v-if="userInfo" 
        trigger="click"
        @command="handleMenuItemClick"
        class="user-dropdown"
        ref="dropdownRef"
      >
        <div class="user-info">
          <el-avatar 
            :size="avatarSize" 
            :src="userInfo.avatar"
            :class="'user-avatar'"
          >
            {{ userInitials }}
          </el-avatar>
          
          <div v-if="showUserDetails" class="user-details">
            <div class="user-name">{{ userInfo.name }}</div>
            <div v-if="userInfo.role" class="user-role">{{ userInfo.role }}</div>
          </div>
          
          <el-icon class="chevron-icon" v-if="showUserDetails">
            <ArrowDown />
          </el-icon>
        </div>
        
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item 
              v-for="(item, index) in userMenuItems" 
              :key="index"
              :divided="item.divided"
              :command="item"
            >
              <el-icon v-if="item.icon">
                <component :is="item.icon" />
              </el-icon>
              <span>{{ item.label }}</span>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ArrowRight, ArrowDown } from '@element-plus/icons-vue'

// 组件属性
const props = defineProps({
  // 页面标题
  pageTitle: {
    type: String,
    default: ''
  },
  // 面包屑路由
  breadcrumbRoutes: {
    type: Array,
    default: () => []
  },
  // 是否显示面包屑
  showBreadcrumb: {
    type: Boolean,
    default: false
  },
  // 是否显示移动端菜单按钮
  showMobileMenuBtn: {
    type: Boolean,
    default: true
  },
  // 用户信息
  userInfo: {
    type: Object,
    default: () => ({
      name: '',
      role: '',
      avatar: ''
    })
  },
  // 是否显示用户详细信息
  showUserDetails: {
    type: Boolean,
    default: true
  },
  // 头像大小
  avatarSize: {
    type: [Number, String],
    default: 36
  },
  // 默认操作按钮
  defaultActions: {
    type: Array,
    default: () => []
  },
  // 用户菜单选项
  userMenuItems: {
    type: Array,
    default: () => [
      // 默认包含退出登录菜单项
      {
          label: '退出登录',
          divided: true,
          action: 'logout'
        }
    ]
  }
})

// 事件
const emit = defineEmits(['toggle-sidebar', 'user-menu-click', 'logout'])

// 计算属性 - 用户首字母
const userInitials = computed(() => {
  if (!props.userInfo?.name) return 'U'
  return props.userInfo.name.charAt(0).toUpperCase()
})

// 处理菜单项点击
const handleMenuItemClick = (item) => {
  emit('user-menu-click', item)
  
  // 处理退出登录操作
  if (item.action === 'logout') {
    handleLogout()
  }
  
  if (item.click && typeof item.click === 'function') {
    item.click()
  }
}

// 下拉菜单引用
const dropdownRef = ref(null)

// 处理退出登录
const handleLogout = () => {
  // 发出退出登录事件，让父组件处理实际的退出逻辑
  emit('logout')
  // 不需要手动关闭菜单，通常在退出后会跳转页面或刷新，菜单自然会关闭
}

// 生命周期不需要额外的事件监听，Element Plus会自动处理下拉菜单的显示/隐藏
</script>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  height: 64px;
  background-color: #ffffff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  position: relative;
  z-index: 90;
}

/* 左侧区域 */
.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-shrink: 0;
}

.mobile-menu-btn {
  display: flex;
  align-items: center;
  justify-content: center;
}

.breadcrumb-container {
  font-size: 14px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
}

/* 中间区域 */
.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 0 20px;
}

/* 右侧区域 */
.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.action-btn {
  position: relative;
  color: #606266;
  transition: color 0.3s ease;
}

.action-btn:hover {
  color: #409eff;
}

.action-badge {
  position: absolute;
  top: 0;
  right: 0;
  min-width: 18px;
  height: 18px;
  padding: 0 6px;
  font-size: 12px;
  line-height: 18px;
  text-align: center;
  background-color: #f56c6c;
  color: #ffffff;
  border-radius: 9px;
  transform: translate(50%, -50%);
}

/* 用户信息 */
.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: background-color 0.3s ease;
}

.user-info:hover {
  background-color: #f5f7fa;
}

.user-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  cursor: pointer;
}

.user-details {
  transition: opacity 0.3s ease;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #2c3e50;
  white-space: nowrap;
}

.user-role {
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
}

.chevron-icon {
  font-size: 14px;
  transition: transform 0.3s ease;
}

/* 用户下拉菜单 */
.user-dropdown {
  position: relative;
}

.user-dropdown .el-dropdown-menu {
  min-width: 160px;
}

.user-dropdown .el-dropdown-menu__item {
  padding: 10px 20px;
  font-size: 14px;
}

.user-dropdown .el-dropdown-menu__item:hover {
  background-color: #f5f7fa;
  color: #409eff;
}

/* 下拉菜单过渡动画 */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .page-title {
    font-size: 18px;
  }
  
  .header-center {
    display: none;
  }
}

@media (max-width: 768px) {
  .app-header {
    padding: 0 16px;
  }
  
  .mobile-menu-btn {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .breadcrumb-container {
    display: none;
  }
  
  .user-details {
    display: none;
  }
  
  .header-right {
    gap: 8px;
  }
  
  .header-actions {
    gap: 4px;
  }
}

/* 暗色主题支持 */
:global(.dark-theme) .app-header {
  background-color: #2a2a2a;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

:global(.dark-theme) .page-title {
  color: #ffffff;
}

:global(.dark-theme) .user-name {
  color: #ffffff;
}

:global(.dark-theme) .user-role {
  color: #aaaaaa;
}

:global(.dark-theme) .action-btn {
  color: #cccccc;
}

:global(.dark-theme) .action-btn:hover {
  color: #409eff;
}

:global(.dark-theme) .user-info:hover {
  background-color: #333333;
}

:global(.dark-theme) .user-dropdown-menu {
  background-color: #2a2a2a;
  border: 1px solid #3a3a3a;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
}

:global(.dark-theme) .user-dropdown-menu .el-dropdown-item {
  color: #cccccc;
}

:global(.dark-theme) .user-dropdown-menu .el-dropdown-item:hover {
  background-color: #333333;
  color: #409eff;
}
</style>