# Agent Studio Lite 云端Docker部署过程

> 本文档包含开发环境和生产环境的部署指南

## 1. 环境准备

### 1.1 系统要求
- **操作系统**：Ubuntu 20.04 LTS 或更高版本
- **Docker**：20.10.0+
- **Docker Compose**：2.0.0+
- **Git**：2.0+
- **内存**：至少4GB RAM（生产环境建议8GB+）
- **磁盘空间**：至少20GB可用空间（生产环境建议50GB+）

### 1.2 安装必要软件

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose
sudo apt install docker-compose-plugin -y

# 安装Git
sudo apt install git -y

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
newgrp docker
```

## 2. 项目获取

```bash
# 克隆项目代码
git clone [项目仓库地址] Agent-Studio-Lite
cd Agent-Studio-Lite

# 设置部署脚本执行权限
chmod +x deploy.sh
```

## 3. 配置文件设置

### 3.1 环境变量配置

#### 开发环境配置

复制环境变量示例文件并根据实际情况修改：

```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑环境变量文件
nano .env
```

**`.env`文件配置说明**：

```
# 数据库配置
MYSQL_ROOT_PASSWORD=root123456
MYSQL_DATABASE=agent_workflow
MYSQL_USER=workflow_user
MYSQL_PASSWORD=workflow_pass_123
MYSQL_HOST=mysql
MYSQL_PORT=3306

# Redis配置
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=workflow_redis123456

# 后端服务配置
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# JWT配置
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRATION=86400000

# 前端配置
VITE_API_BASE_URL=http://localhost:8080/api

# 服务端口配置
FRONTEND_PORT=80
BACKEND_PORT=8080
MYSQL_EXTERNAL_PORT=3306
REDIS_EXTERNAL_PORT=6379
PHPMYADMIN_PORT=8081
```

#### 生产环境配置

复制生产环境变量文件并根据实际情况修改：

```bash
# 复制生产环境变量文件
cp .env.prod .env.prod

# 编辑生产环境变量文件
nano .env.prod
```

**`.env.prod`文件配置注意事项**：
1. 务必修改所有默认密码和密钥
2. 设置强密码策略
3. 配置正确的生产环境域名
4. 根据服务器资源调整性能参数

## 4. 一键部署

### 4.1 部署脚本使用说明

部署脚本支持多环境部署，提供了以下选项：

```bash
# 查看帮助信息
./deploy.sh --help

# 部署开发环境（默认）
./deploy.sh
或
./deploy.sh --dev

# 部署生产环境
./deploy.sh --prod

# 生产环境部署前备份数据
./deploy.sh --prod --backup

# 生产环境回滚
./deploy.sh --prod --rollback
```

### 4.2 开发环境部署

```bash
./deploy.sh
```

### 4.3 生产环境部署

```bash
# 首次部署
./deploy.sh --prod

# 带备份的部署
./deploy.sh --prod --backup
```

## 5. 部署脚本详细说明 (`deploy.sh`)

部署脚本功能概述：

1. **多环境支持**：支持开发环境和生产环境部署
2. **环境检查**：验证Docker、Docker Compose等依赖是否安装
3. **配置文件验证**：检查必要的配置文件是否存在
4. **生产环境安全检查**：检查默认密码等安全问题
5. **备份功能**：生产环境部署前可选择备份数据
6. **回滚功能**：支持回滚到上一个版本
7. **自动清理**：自动清理旧的容器和网络
8. **服务健康检查**：生产环境部署后自动执行健康检查

## 6. Dockerfile 详细说明

### 6.1 后端 Dockerfile (`Back-end/Dockerfile`)

```dockerfile
# 第一阶段：构建阶段
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制Maven配置文件
COPY pom.xml .

# 下载依赖（利用Docker缓存层）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 构建应用
RUN mvn package -DskipTests

# 第二阶段：运行阶段
FROM eclipse-temurin:17-jre-alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/back-end-1.0.0.jar app.jar

# 设置环境变量
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# 暴露端口
EXPOSE 8080

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 6.2 前端 Dockerfile (`Front-end/Dockerfile`)

```dockerfile
# 第一阶段：构建阶段
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 第二阶段：运行阶段
FROM nginx:1.25-alpine

# 复制构建产物到Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制自定义Nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]
```

## 7. Docker Compose 配置

### 7.1 开发环境配置 (`docker-compose.yml`)

```yaml
version: '3.8'

services:
  # 前端服务
  frontend:
    build:
      context: ./Front-end
      dockerfile: Dockerfile
    container_name: agent-studio-lite-frontend
    ports:
      - "${FRONTEND_PORT:-80}:80"
    depends_on:
      - backend
    networks:
      - agent-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 后端服务
  backend:
    build:
      context: ./Back-end
      dockerfile: Dockerfile
    container_name: agent-studio-lite-backend
    ports:
      - "${BACKEND_PORT:-8080}:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-prod}
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/${MYSQL_DATABASE:-agent_workflow}?useSSL=false&serverTimezone=UTC
      - SPRING_DATASOURCE_USERNAME=${MYSQL_USER:-workflow_user}
      - SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD:-workflow_pass_123}
      - SPRING_REDIS_HOST=${REDIS_HOST:-redis}
      - SPRING_REDIS_PORT=${REDIS_PORT:-6379}
      - SPRING_REDIS_PASSWORD=${REDIS_PASSWORD:-workflow_redis123456}
      - JWT_SECRET=${JWT_SECRET:-your_jwt_secret_key_here}
      - JWT_EXPIRATION=${JWT_EXPIRATION:-86400000}
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - agent-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # MySQL数据库
  mysql:
    image: mysql:8.0
    container_name: agent-studio-lite-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root123456}
      - MYSQL_DATABASE=${MYSQL_DATABASE:-agent_workflow}
      - MYSQL_USER=${MYSQL_USER:-workflow_user}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD:-workflow_pass_123}
    ports:
      - "${MYSQL_EXTERNAL_PORT:-3306}:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./Database/init:/docker-entrypoint-initdb.d
    networks:
      - agent-network
    command:
      - --default-authentication-plugin=mysql_native_password
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p$MYSQL_ROOT_PASSWORD"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis缓存
  redis:
    image: redis:7-alpine
    container_name: agent-studio-lite-redis
    ports:
      - "${REDIS_EXTERNAL_PORT:-6379}:6379"
    environment:
      - REDIS_PASSWORD=${REDIS_PASSWORD:-workflow_redis123456}
    command: redis-server --requirepass ${REDIS_PASSWORD:-workflow_redis123456} --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - agent-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  # phpMyAdmin数据库管理工具
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: agent-studio-lite-phpmyadmin
    environment:
      - PMA_HOST=mysql
      - PMA_PORT=3306
      - PMA_USER=root
      - PMA_PASSWORD=${MYSQL_ROOT_PASSWORD:-root123456}
    ports:
      - "${PHPMYADMIN_PORT:-8081}:80"
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - agent-network
    restart: unless-stopped

# 持久化卷
volumes:
  mysql_data:
    driver: local
  redis_data:
    driver: local

# 网络配置
networks:
  agent-network:
    driver: bridge
```

### 7.2 生产环境配置 (`docker-compose.prod.yml`)

生产环境配置相比开发环境有以下主要优化：

1. **资源限制**：为每个服务设置CPU和内存限制，避免资源争用
2. **安全性增强**：移除不必要的端口暴露，启用MySQL SSL连接
3. **性能优化**：增加JVM内存分配，调整数据库参数
4. **移除开发工具**：移除phpMyAdmin等仅用于开发的服务
5. **数据持久化改进**：配置更可靠的卷挂载方式
6. **健康检查优化**：增加启动宽限期，更严格的健康检查策略
7. **固定版本**：使用固定的镜像版本而非latest，确保稳定性

## 8. 部署完成后验证

### 8.1 检查服务状态

```bash
# 开发环境查看服务状态
docker compose ps

# 生产环境查看服务状态
docker compose -f docker-compose.prod.yml ps

# 查看各服务日志
docker compose -f [docker-compose文件] logs -f
```

### 8.2 访问服务

- **前端应用**：http://服务器IP:80
- **后端API**：http://服务器IP:8080

> **注意**：生产环境默认不暴露phpMyAdmin和数据库端口，如需管理数据库，可通过以下方式临时启动phpMyAdmin：
> ```bash
> # 临时启动phpMyAdmin并映射到127.0.0.1:8081
> docker run --rm -d --name phpmyadmin-temp \
>   -e PMA_HOST=agent-studio-lite-mysql \
>   -e PMA_USER=root \
>   -e PMA_PASSWORD=您的根密码 \
>   -p 127.0.0.1:8081:80 \
>   --network agent_network \
>   phpmyadmin/phpmyadmin
> ```

### 8.3 常见问题排查

1. **服务无法启动**：
   - 检查端口是否被占用
   - 检查环境变量配置是否正确
   - 查看日志获取详细错误信息

2. **数据库连接失败**：
   - 确认MySQL服务已正常运行
   - 验证数据库用户名和密码配置
   - 检查网络连接和防火墙设置

3. **前端无法访问后端API**：
   - 确认后端服务已正常运行
   - 检查API路径配置是否正确
   - 验证CORS设置（如果需要）

## 9. 扩展与维护

### 9.1 数据备份

#### 开发环境备份

```bash
# 备份MySQL数据库
docker exec agent-studio-lite-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > backup_$(date +%Y%m%d).sql

# 备份Redis数据
docker exec agent-studio-lite-redis redis-cli -a ${REDIS_PASSWORD} save
```

#### 生产环境备份

生产环境建议使用部署脚本的备份功能：

```bash
# 执行备份并部署
./deploy.sh --prod --backup

# 或手动备份卷数据
mkdir -p backups
BACKUP_FILE="backups/agent-studio-lite-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$BACKUP_FILE" volumes/ .env.prod docker-compose.prod.yml
```

### 9.2 升级应用

```bash
# 拉取最新代码
git pull

# 开发环境重新部署
./deploy.sh

# 生产环境重新部署（建议先备份）
./deploy.sh --prod --backup
```

### 9.3 生产环境回滚

如果新部署的版本出现问题，可以使用回滚功能恢复到上一个版本：

```bash
./deploy.sh --prod --rollback
```

### 9.4 扩展配置

- **增加内存**：修改docker-compose.prod.yml中的resources配置
- **水平扩展**：使用Docker Swarm或Kubernetes进行集群部署
- **负载均衡**：前置Nginx或云服务负载均衡器
- **HTTPS配置**：配置SSL证书，修改前端Nginx配置

## 10. 安全注意事项

### 10.1 生产环境特有安全措施

1. **务必修改所有默认密码**，特别是数据库密码和JWT密钥
2. **配置HTTPS**加密传输
3. **定期更新Docker镜像**和依赖
4. **配置防火墙规则**限制访问，仅开放必要端口
5. **使用密钥管理服务**存储敏感信息，避免直接在环境变量中暴露
6. **定期审计日志**，监控异常访问
7. **实施网络分段**，隔离不同服务
8. **定期备份数据**，并测试恢复流程

### 10.2 环境变量保护

- 确保.env.prod文件已添加到.gitignore
- 考虑使用环境变量管理服务或密钥管理服务
- 定期轮换敏感凭证

## 11. 监控与日志

### 11.1 日志管理

```bash
# 查看所有服务日志
docker compose -f docker-compose.prod.yml logs

# 跟踪日志
docker compose -f docker-compose.prod.yml logs -f

# 查看特定服务日志
docker compose -f docker-compose.prod.yml logs [服务名]
```

### 11.2 性能监控

对于生产环境，建议配置外部监控工具：

1. **Prometheus + Grafana**：监控系统资源和应用性能
2. **ELK Stack**：集中管理和分析日志
3. **Docker Dashboard**：监控容器状态

## 12. 开发环境与生产环境的主要区别

| 特性 | 开发环境 | 生产环境 |
|------|---------|----------|
| 资源配置 | 较低，适合开发 | 较高，优化性能 |
| 端口暴露 | 暴露多个端口便于开发 | 仅暴露必要端口 |
| 数据库工具 | 包含phpMyAdmin | 不包含开发工具 |
| 安全设置 | 基本安全设置 | 增强安全设置 |
| 日志级别 | 详细日志 | 标准日志级别 |
| 备份策略 | 手动备份 | 自动备份机制 |
| 版本控制 | 灵活版本 | 固定版本确保稳定性 |
| 健康检查 | 基本检查 | 严格的健康检查策略 |