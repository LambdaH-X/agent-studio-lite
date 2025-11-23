<template>
  <div class="sidebar">
    <!-- 侧边栏头部 -->
    <div class="sidebar-header" v-if="showHeader">
      <div class="logo-container" v-if="logo">
        <div v-if="typeof logo === 'string' && logo.includes('://')" class="logo-image">
          <img :src="logo" :alt="title || 'Logo'" />
        </div>
        <div v-else class="logo-text">
          {{ logo }}
        </div>
      </div>
      <h2 v-if="title" class="sidebar-title">{{ title }}</h2>
   
    </div>
    
    <!-- 导航菜单 -->
    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li 
          v-for="(item, index) in menuItems" 
          :key="index"
          class="nav-item"
          :class="{ 
            'active': isActive(item),
            'has-children': item.children && item.children.length > 0
          }"
        >
          <!-- 菜单项 -->
          <div 
            v-if="!item.children || item.children.length === 0" 
            class="nav-link"
            @click="handleItemClick(item)"
          >
            <div class="nav-icon" v-if="item.icon">
              <el-icon v-if="isIconComponent(item.icon)">
                <component :is="item.icon" />
              </el-icon>
              <span v-else>{{ item.icon }}</span>
            </div>
            <span class="nav-text">{{ item.label }}</span>
          </div>
          
          <!-- 有子菜单的项 -->
          <div v-else class="nav-item-wrapper">
            <div 
              class="nav-link nav-parent"
              @click="toggleSubmenu(index)"
            >
              <div class="nav-icon" v-if="item.icon">
                <el-icon v-if="isIconComponent(item.icon)">
                  <component :is="item.icon" />
                </el-icon>
                <span v-else>{{ item.icon }}</span>
              </div>
              <span class="nav-text">{{ item.label }}</span>
              <el-icon class="chevron-icon">
                <ArrowDown :rotate="expandedMenus.includes(index) ? 180 : 0" />
              </el-icon>
            </div>
            
            <!-- 子菜单 -->
            <ul 
              class="submenu"
              :class="{ 'expanded': expandedMenus.includes(index) }"
            >
              <li 
                v-for="(child, childIndex) in item.children" 
                :key="childIndex"
                class="submenu-item"
                :class="{ 'active': isActive(child) }"
              >
                <div 
                  class="submenu-link"
                  @click="handleItemClick(child)"
                >
                  <span class="submenu-text">{{ child.label }}</span>
                </div>
              </li>
            </ul>
          </div>
        </li>
      </ul>
    </nav>
    
    <!-- 侧边栏底部 -->
    <div class="sidebar-footer" v-if="hasFooter">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
// Element Plus icons are globally registered in main.js

const route = useRoute()
const router = useRouter()

// 组件属性
const props = defineProps({
  // 菜单数据
  menuItems: {
    type: Array,
    default: () => []
  },
  // 是否折叠
  collapsed: {
    type: Boolean,
    default: false
  },
  // 是否显示头部
  showHeader: {
    type: Boolean,
    default: true
  },
  // Logo (可以是文本、emoji或URL)
  logo: {
    type: String,
    default: '🤖'
  },
  // 标题
  title: {
    type: String,
    default: 'Agent Studio Lite'
  },
  // 是否有底部
  hasFooter: {
    type: Boolean,
    default: false
  },
  // 激活类名
  activeClass: {
    type: String,
    default: 'active'
  },

})

// 展开的子菜单
const expandedMenus = ref([])

// 事件
const emit = defineEmits(['toggle', 'item-click'])

// 计算属性 - 是否折叠
const isCollapsed = computed(() => props.collapsed)

// 检查是否为Element Plus图标组件
const isIconComponent = (icon) => {
  // 字符串形式的图标名称也应该被视为图标组件
  return typeof icon === 'string' || (typeof icon === 'object' && icon !== null && 'name' in icon)
}

// 检查菜单项是否激活
const isActive = (item) => {
  if (!item.path) return false
  
  // 精确匹配
  if (route.path === item.path) return true
  
  // 前缀匹配（用于嵌套路由）
  if (item.path.endsWith('/') && route.path.startsWith(item.path)) return true
  
  return false
}

// 切换子菜单展开状态
const toggleSubmenu = (index) => {
  if (expandedMenus.value.includes(index)) {
    expandedMenus.value = expandedMenus.value.filter(i => i !== index)
  } else {
    expandedMenus.value.push(index)
  }
}

// 处理菜单项点击
const handleItemClick = (item) => {
  // 触发点击事件
  emit('item-click', item)
  
  // 如果有路径则导航
  if (item.path) {
    router.push(item.path)
  }
  
  // 如果有点击回调则执行
  if (item.click && typeof item.click === 'function') {
    item.click()
  }
}
</script>

<style scoped>
.sidebar {
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 侧边栏头部 */
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.logo-image img {
  max-width: 40px;
  max-height: 40px;
  border-radius: 8px;
}

.logo-text {
  font-size: 24px;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  color: white;
}

.sidebar-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.toggle-sidebar-btn {
  color: #409eff;
  background-color: rgba(64, 158, 255, 0.1);
  border-radius: 4px;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  min-width: 36px;
  height: 36px;
}

.toggle-sidebar-btn:hover {
  color: #ffffff;
  background-color: #409eff;
}

/* 导航菜单 */
.sidebar-nav {
  flex: 1;
  padding: 20px 0;
  overflow-y: auto;
}

.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-item {
  margin-bottom: 4px;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  color: #606266;
  text-decoration: none;
  border-radius: 8px;
  transition: all 0.3s ease;
  font-size: 14px;
  cursor: pointer;
  white-space: nowrap;
}

.nav-link:hover {
  background-color: #f5f7fa;
  color: #409eff;
}

.nav-item.active .nav-link {
  background-color: #ecf5ff;
  color: #409eff;
  font-weight: 500;
}

.nav-icon {
  font-size: 18px;
  width: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 激活状态的图标阴影效果 */
.nav-item.active .nav-icon {
  box-shadow: 0 0 8px rgba(64, 158, 255, 0.5);
  border-radius: 4px;
  padding: 4px;
  background-color: rgba(64, 158, 255, 0.1);
}

.nav-text {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
}

.nav-parent {
  justify-content: space-between;
}

.chevron-icon {
  font-size: 14px;
  transition: transform 0.3s ease;
}

/* 子菜单 */
.submenu {
  list-style: none;
  padding: 0;
  margin: 0;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
}

.submenu.expanded {
  max-height: 500px;
}

.submenu-item {
  margin: 0;
}

.submenu-link {
  display: flex;
  align-items: center;
  padding: 8px 20px 8px 52px;
  color: #606266;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.submenu-link:hover {
  background-color: #f5f7fa;
  color: #409eff;
  padding-left: 56px;
}

.submenu-item.active .submenu-link {
  background-color: #ecf5ff;
  color: #409eff;
  font-weight: 500;
  padding-left: 56px;
}

/* 侧边栏底部 */
.sidebar-footer {
  padding: 20px;
  border-top: 1px solid #f0f0f0;
  background-color: #ffffff;
}

/* 折叠状态样式 */
.collapsed .sidebar-title,
.collapsed .nav-text,
.collapsed .submenu,
.collapsed .chevron-icon,
.collapsed .sidebar-footer .user-details {
  display: none;
}

.collapsed .nav-link {
  justify-content: center;
  padding: 12px 8px;
}

.collapsed .sidebar-footer {
  padding: 16px;
  display: flex;
  justify-content: center;
}

.collapsed .nav-icon {
  display: flex !important;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 24px;
  color: #606266;
}

.collapsed .logo-container {
  justify-content: center;
}

/* 滚动条样式 */
.sidebar-nav::-webkit-scrollbar {
  width: 4px;
}

.sidebar-nav::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.sidebar-nav::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 2px;
}

.sidebar-nav::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* 暗色主题支持 */
:global(.dark-theme) .sidebar-header,
:global(.dark-theme) .sidebar-footer {
  border-color: #3a3a3a;
}

:global(.dark-theme) .nav-link,
:global(.dark-theme) .submenu-link {
  color: #cccccc;
}

:global(.dark-theme) .nav-link:hover,
:global(.dark-theme) .submenu-link:hover {
  background-color: #333333;
  color: #409eff;
}

:global(.dark-theme) .nav-item.active .nav-link,
:global(.dark-theme) .submenu-item.active .submenu-link {
  background-color: rgba(64, 158, 255, 0.15);
  color: #409eff;
}

:global(.dark-theme) .sidebar-title {
  color: #ffffff;
}

:global(.dark-theme) .sidebar-nav::-webkit-scrollbar-track {
  background: #2a2a2a;
}

:global(.dark-theme) .sidebar-nav::-webkit-scrollbar-thumb {
  background: #555555;
}

:global(.dark-theme) .sidebar-nav::-webkit-scrollbar-thumb:hover {
  background: #777777;
}
</style>