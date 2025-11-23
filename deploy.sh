#!/bin/bash

# Agent Studio Lite 一键部署脚本（仅支持Linux环境）
set -e

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# 检查是否在Linux环境中运行
if [[ "$(uname)" != "Linux" ]]; then
    echo -e "${RED}错误：此脚本仅支持在Linux环境中运行${NC}"
    echo -e "请使用Windows专用脚本 deploy-dev.ps1 或 deploy-prod.ps1"
    exit 1
fi

# 默认环境和配置
env="dev"
compose_file=""
compose_file_name=""

# 显示帮助信息
show_help() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     Agent Studio Lite 部署脚本     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "使用方法: $0 [选项]"
    echo -e ""
    echo -e "选项:"
    echo -e "  -h, --help      显示帮助信息"
    echo -e "  -d, --dev       部署开发环境 (默认)"
    echo -e "  -p, --prod      部署生产环境"
    echo -e "  -t, --test      部署测试环境"
    echo -e "  -f, --file      指定docker-compose文件路径"
    echo -e "  --compose-dev   使用docker-compose.yml文件（测试环境）"
    echo -e "  --compose-prod  使用docker-compose.prod.yml文件（生产环境）"
    echo -e "  -b, --backup    部署前备份数据（仅生产环境可用）"
    echo -e "  -r, --rollback  回滚到上一个版本（仅生产环境可用）"
    echo -e "  --dry-run       只显示将要执行的命令，不实际执行"
    echo -e ""
    echo -e "示例:"
    echo -e "  $0 --compose-dev      # 部署测试环境（使用docker-compose.yml）"
    echo -e "  $0 --compose-prod     # 部署生产环境（使用docker-compose.prod.yml）"
    echo -e "  $0 -f custom-compose.yml  # 使用自定义docker-compose文件"
    echo -e ""
}

# 解析命令行参数
dry_run=false
test_mode=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dev)
            env="dev"
            if [ -z "$compose_file" ]; then
                compose_file="docker-compose.yml"
                compose_file_name="docker-compose.yml"
            fi
            shift
            ;;
        -p|--prod)
            env="prod"
            if [ -z "$compose_file" ]; then
                compose_file="docker-compose.prod.yml"
                compose_file_name="docker-compose.prod.yml"
            fi
            shift
            ;;
        -t|--test)
            env="test"
            if [ -z "$compose_file" ]; then
                compose_file="docker-compose.yml"
                compose_file_name="docker-compose.yml"
            fi
            shift
            ;;
        -f|--file)
            # 允许用户指定自定义docker-compose文件
            if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                compose_file="$2"
                compose_file_name="$(basename "$2")"
                shift 2
            else
                echo -e "${RED}错误: -f 选项需要指定文件路径${NC}"
                show_help
                exit 1
            fi
            ;;
        --compose-dev)
            # 明确使用docker-compose.yml文件（测试环境）
            compose_file="docker-compose.yml"
            compose_file_name="docker-compose.yml"
            env="test"
            shift
            ;;
        --compose-prod)
            # 明确使用docker-compose.prod.yml文件（生产环境）
            compose_file="docker-compose.prod.yml"
            compose_file_name="docker-compose.prod.yml"
            env="prod"
            shift
            ;;
        -b|--backup)
            backup=true
            shift
            ;;
        -r|--rollback)
            rollback=true
            env="prod" # 回滚仅在生产环境可用
            if [ -z "$compose_file" ]; then
                compose_file="docker-compose.prod.yml"
                compose_file_name="docker-compose.prod.yml"
            fi
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;

        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 如果没有明确指定compose文件，则根据环境自动选择
if [ -z "$compose_file" ]; then
    if [ "$env" = "prod" ]; then
        compose_file="docker-compose.prod.yml"
        compose_file_name="docker-compose.prod.yml"
    else
        compose_file="docker-compose.yml"
        compose_file_name="docker-compose.yml"
    fi
fi

# 显示部署信息
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}     Agent Studio Lite 部署脚本     ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "部署环境: ${YELLOW}${env}${NC}"
echo -e "Docker Compose文件: ${YELLOW}${compose_file_name}${NC}"
echo -e "操作系统: ${YELLOW}${OS}${NC}"

# 生产环境确认
if [ "$env" = "prod" ]; then
    echo -e "${YELLOW}警告：您正在准备部署到生产环境！${NC}"
    read -p "是否继续？(y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}部署已取消${NC}"
        exit 0
    fi
    
    # 生产环境安全检查
    echo -e "${YELLOW}[*] 执行生产环境安全检查...${NC}"
    if [ ! -f ".env.prod" ]; then
        echo -e "${RED}错误：未找到生产环境配置文件 .env.prod${NC}"
        echo -e "请先复制 .env.prod 文件并配置相关参数"
        exit 1
    fi
    
    # 检查 .env.prod 中的密码强度
    # 这里仅作为示例，实际项目中可以实现更复杂的密码强度检查
    if grep -q "MySecUr3R00tP@ssw0rd2024\|W0rkfl0w_$3cur3_P@ss2024\|R3d1s_S3cur3_P@ssw0rd2024" .env.prod; then
        echo -e "${YELLOW}警告：检测到默认密码，请确保已修改所有默认密码！${NC}"
        read -p "是否继续使用默认密码？(y/N): " password_confirm
        if [[ ! $password_confirm =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}请修改 .env.prod 文件中的默认密码后重新部署${NC}"
            exit 0
        fi
    fi
fi

# 确认compose文件存在
if [ ! -f "$compose_file" ]; then
    echo -e "${RED}错误：未找到指定的Docker Compose文件: $compose_file${NC}"
    exit 1
fi

# 环境检查
echo -e "${YELLOW}[1/5] 检查部署环境...${NC}"

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误：Docker未安装，请先安装Docker${NC}"
    exit 1
fi

# 检查Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}错误：Docker Compose未安装，请先安装Docker Compose${NC}"
    exit 1
fi

# 根据环境设置环境变量文件
if [ "$env" = "prod" ]; then
    env_file=".env.prod"
    # 加载环境变量用于后续使用
    if [ -f "$env_file" ]; then
        echo -e "${GREEN}加载生产环境配置：$env_file${NC}"
        # Linux环境下加载环境变量
    export $(grep -v '^#' "$env_file" | xargs 2>/dev/null || true)
    fi
elif [ "$env" = "test" ]; then
    # 测试环境配置
    echo -e "${GREEN}使用测试环境配置：$compose_file${NC}"
else
    # 开发环境
    env_file=".env"
    if [ ! -f "$env_file" ]; then
        echo -e "${YELLOW}警告：$env_file 文件不存在，正在从.env.example创建...${NC}"
        if [ -f ".env.example" ]; then
            # 确保复制命令在所有平台上都能工作
            cp .env.example "$env_file"
            echo -e "${GREEN}已创建 $env_file 文件，请根据需要修改配置${NC}"
        else
            echo -e "${YELLOW}警告：.env.example文件也不存在，将继续使用默认配置${NC}"
        fi
    fi
    # 加载环境变量用于后续使用
    if [ -f "$env_file" ]; then
        export $(grep -v '^#' "$env_file" | xargs 2>/dev/null || true)
    fi
fi

# 回滚功能
if [ "$rollback" = true ] && [ "$env" = "prod" ]; then
    echo -e "${YELLOW}[*] 执行回滚操作...${NC}"
    
    # 检查是否有备份
    if [ ! -d "backups" ] || [ -z "$(ls -A backups 2>/dev/null)" ]; then
        echo -e "${RED}错误：未找到备份文件，无法回滚${NC}"
        exit 1
    fi
    
    # 获取最新备份
    latest_backup=$(ls -t backups/ | head -1)
    
    echo -e "${GREEN}将回滚到备份: $latest_backup${NC}"
    
    # 停止当前服务
    docker compose -f "$compose_file" down -v --remove-orphans || true
    
    # 恢复备份
    echo -e "${YELLOW}正在恢复备份...${NC}"
    # 确保tar命令在所有平台上都能工作
    tar -xzf "backups/$latest_backup" -C .
    
    # 启动服务
    echo -e "${YELLOW}正在启动服务...${NC}"
    docker compose -f "$compose_file" up -d
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}回滚完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
fi

# 备份功能（仅生产环境）
if [ "$backup" = true ] && [ "$env" = "prod" ]; then
    echo -e "${YELLOW}[*] 执行备份操作...${NC}"
    
    # 创建备份目录
    mkdir -p backups
    
    # 备份文件名
    backup_file="backups/agent-studio-lite-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # 如果服务正在运行，先停止服务
    if docker compose -f "$compose_file" ps | grep -q "Up"; then
        echo -e "${YELLOW}停止服务以进行备份...${NC}"
        docker compose -f "$compose_file" down -v --remove-orphans || true
    fi
    
    # 备份数据目录和配置文件
    echo -e "${YELLOW}创建备份...${NC}"
    # 确保tar命令在所有平台上都能工作
    tar -czf "$backup_file" volumes/ .env.prod docker-compose.prod.yml
    
    echo -e "${GREEN}备份完成: $backup_file${NC}"
    
    # 清理旧备份（保留最近7个）
    echo -e "${YELLOW}清理旧备份，保留最近7个...${NC}"
    # Linux环境下使用find命令查找并删除旧备份
    (cd backups && ls -t | tail -n +8 | xargs -r rm -f)
    echo -e "${GREEN}备份清理完成${NC}"

# 执行命令函数 - 支持dry-run模式
execute_command() {
    local cmd="$1"
    local desc="$2"
    
    if [ ! -z "$desc" ]; then
        echo -e "${BLUE}$desc${NC}"
    fi
    
    echo -e "${YELLOW}执行: $cmd${NC}"
    
    if [ "$dry_run" = true ]; then
        echo -e "${YELLOW}DRY RUN模式 - 不实际执行命令${NC}"
        return 0
    fi
    
    # Linux环境下执行命令
    eval "$cmd"
    return $?
}

# 清理旧的容器和网络
echo -e "${YELLOW}[2/5] 清理旧的服务...${NC}"
execute_command "docker compose -f \"$compose_file\" down -v --remove-orphans || true" "停止并移除现有服务..."

# 创建必要的目录
mkdir -p volumes/mysql volumes/redis

# Linux环境中设置适当的权限
echo -e "${YELLOW}设置目录权限...${NC}"
chmod -R 755 volumes/
chmod -R 777 volumes/mysql volumes/redis  # MySQL和Redis需要写入权限

# 构建Docker镜像
echo -e "${YELLOW}[3/5] 构建Docker镜像...${NC}"
execute_command "docker compose -f \"$compose_file\" build" "构建Docker镜像..."

# 启动服务
echo -e "${YELLOW}[4/5] 启动服务...${NC}"
execute_command "docker compose -f \"$compose_file\" up -d" "启动Docker服务..."

# 等待服务就绪并显示状态
echo -e "${YELLOW}[5/5] 等待服务就绪...${NC}"
sleep 15
execute_command "docker compose -f \"$compose_file\" ps" "显示服务状态..."

# 显示服务状态
echo -e "${GREEN}\n========================================${NC}"
echo -e "${GREEN}服务部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "环境: ${YELLOW}${env}${NC}"
echo -e "Docker Compose文件: ${YELLOW}${compose_file_name}${NC}"

# 根据使用的compose文件显示不同的端口信息
if [ "$compose_file_name" = "docker-compose.yml" ]; then
    # 测试环境端口配置
    echo -e "前端地址:${NC} http://localhost:81"
    echo -e "后端API:${NC} http://localhost:8082"
    echo -e "数据库管理工具:${NC} http://localhost:8083"

elif [ "$compose_file_name" = "docker-compose.prod.yml" ]; then
    # 生产环境端口配置
    echo -e "前端地址:${NC} http://localhost:${FRONTEND_PORT:-80}"

else
    # 自定义compose文件，显示通用信息
    echo -e "请查看 $compose_file_name 文件中的端口映射配置"
fi

# Linux环境使用提示
echo -e "\n${YELLOW}Linux环境注意事项:${NC}"
echo -e "1. 首次运行前，请确保脚本有执行权限:${BLUE}chmod +x deploy.sh${NC}"

# 显示通用使用说明
echo -e "\n${YELLOW}使用说明:${NC}"
echo -e "1. 部署测试环境: ${BLUE}./deploy.sh --compose-dev${NC}"
echo -e "2. 部署生产环境: ${BLUE}./deploy.sh --compose-prod${NC}"
echo -e "3. 使用自定义Compose文件: ${BLUE}./deploy.sh -f <file>${NC}"
echo -e "4. 查看服务状态: ${BLUE}docker compose -f $compose_file_name ps${NC}"
echo -e "5. 查看日志: ${BLUE}docker compose -f $compose_file_name logs -f${NC}"

# 生产环境特有信息
if [ "$env" = "prod" ]; then
    echo -e "${YELLOW}\n生产环境注意事项:${NC}"
    echo -e "1. 确保已修改所有默认密码"
    echo -e "2. 建议配置HTTPS"
    echo -e "3. 定期检查日志和监控系统"
    echo -e "4. 定期备份数据"
    echo -e "5. 如需回滚，请使用: ./deploy.sh --compose-prod --rollback"
fi

# 对于生产环境和测试环境，运行健康检查
if [ "$env" = "prod" ] || [ "$env" = "test" ]; then
    echo -e "${YELLOW}\n执行健康检查...${NC}"
    sleep 10
    if docker compose -f "$compose_file" ps | grep -q "healthy"; then
        echo -e "${GREEN}所有服务健康检查通过！${NC}"
    else
        echo -e "${YELLOW}部分服务可能尚未完全启动，请稍后再检查${NC}"
    fi
fi