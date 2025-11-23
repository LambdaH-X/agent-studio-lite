# Agent Studio Lite

一个轻量级的Agent工作流管理系统，支持任务配置、执行和监控。

## 技术栈

- **后端**: Java
- **前端**: Vue.js
- **数据库**: MySQL
- **缓存**: Redis
- **容器化**: Docker

## 项目结构

```
├── Back-end/       # Java后端代码
├── Front-end/      # Vue.js前端代码
├── Database/       # 数据库初始化脚本
├── volumes/        # 数据持久化目录
```

## 快速开始

### 前置条件

- Docker 环境
- Docker Compose

### Linux环境部署

```bash
# 测试环境部署
./deploy.sh --compose-dev

# 生产环境部署
./deploy.sh --compose-prod
```

### Windows环境部署

```powershell
# 测试环境部署
.\deploy-dev.ps1

# 生产环境部署
.\deploy-prod.ps1
```

## 服务访问

测试环境:
- 前端: http://localhost:81
- 后端API: http://localhost:8082
- phpMyAdmin: http://localhost:8083

生产环境:
- 前端: http://localhost
- 后端API: http://localhost:8082

## 环境变量配置

复制示例文件并修改配置:

```bash
cp .env.example .env
```

## 注意事项

- 生产环境部署前请确保修改数据库密码等敏感信息
- 定期备份数据库和重要数据