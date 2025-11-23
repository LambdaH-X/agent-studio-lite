#!/usr/bin/env pwsh

# Agent Studio Lite 测试环境一键部署脚本（仅支持Windows环境）

# 颜色定义
function Write-ColorOutput {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White
    )
    $previousColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Text
    $Host.UI.RawUI.ForegroundColor = $previousColor
}

# 错误处理函数
function Handle-Error {
    param(
        [string]$Message
    )
    Write-ColorOutput "错误：$Message" -Color Red
    exit 1
}

# 检查是否在Windows环境中运行
if (-not $IsWindows -and -not ([System.Environment]::OSVersion.VersionString -match 'Windows')) {
    Handle-Error "此脚本仅支持在Windows环境中运行"
}

# 定义变量
$composeFile = "docker-compose.yml"
$composeFileName = Split-Path -Path $composeFile -Leaf
$env = "test"
$dryRun = $false

# 显示脚本信息
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "     Agent Studio Lite 部署脚本     " -Color Green
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "部署环境: 测试环境" -Color Yellow
Write-ColorOutput "Docker Compose文件: $composeFileName" -Color Yellow
Write-ColorOutput "操作系统: Windows" -Color Yellow

# 确认compose文件存在
if (-not (Test-Path $composeFile)) {
    Handle-Error "未找到指定的Docker Compose文件: $composeFile"
}

# 环境检查
Write-ColorOutput "[1/5] 检查部署环境..." -Color Yellow

# 检查Docker
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Handle-Error "Docker未安装，请先安装Docker"
}

# 检查Docker Compose
if (-not (Get-Command "docker-compose" -ErrorAction SilentlyContinue) -and -not (Get-Command "docker compose" -ErrorAction SilentlyContinue)) {
    Handle-Error "Docker Compose未安装，请先安装Docker Compose"
}

# 执行命令函数
function Execute-Command {
    param(
        [string]$Command,
        [string]$Description
    )
    
    if (-not [string]::IsNullOrEmpty($Description)) {
        Write-ColorOutput $Description -Color Blue
    }
    
    Write-ColorOutput "执行: $Command" -Color Yellow
    
    if ($dryRun) {
        Write-ColorOutput "DRY RUN模式 - 不实际执行命令" -Color Yellow
        return 0
    }
    
    try {
        # 在Windows PowerShell中执行命令
        Invoke-Expression $Command
        return $LASTEXITCODE
    } catch {
        Write-ColorOutput "命令执行失败: $_" -Color Red
        return 1
    }
}

# 清理旧的容器和网络
Write-ColorOutput "[2/5] 清理旧的服务..." -Color Yellow
Execute-Command "docker compose -f \"$composeFile\" down -v --remove-orphans 2>$null || echo '无现有服务需要移除'" "停止并移除现有服务..."

# 创建必要的目录
if (-not (Test-Path "volumes")) {
    New-Item -ItemType Directory -Path "volumes/mysql" -Force | Out-Null
    New-Item -ItemType Directory -Path "volumes/redis" -Force | Out-Null
    Write-ColorOutput "已创建必要的数据目录" -Color Green
}

# 构建Docker镜像
Write-ColorOutput "[3/5] 构建Docker镜像..." -Color Yellow
Execute-Command "docker compose -f \"$composeFile\" build" "构建Docker镜像..."

# 启动服务
Write-ColorOutput "[4/5] 启动服务..." -Color Yellow
Execute-Command "docker compose -f \"$composeFile\" up -d" "启动Docker服务..."

# 等待服务就绪并显示状态
Write-ColorOutput "[5/5] 等待服务就绪..." -Color Yellow
Write-ColorOutput "等待15秒让服务初始化..." -Color Yellow
Start-Sleep -Seconds 15
Execute-Command "docker compose -f \"$composeFile\" ps" "显示服务状态..."

# 显示服务状态
Write-ColorOutput "\n========================================" -Color Green
Write-ColorOutput "服务部署完成！" -Color Green
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "环境: 测试环境" -Color Yellow
Write-ColorOutput "Docker Compose文件: $composeFileName" -Color Yellow

# 显示访问地址（根据docker-compose.yml中的端口配置）
Write-ColorOutput "\n服务访问地址:" -Color White
Write-ColorOutput "前端地址: http://localhost:81" -Color White
Write-ColorOutput "后端API: http://localhost:8082" -Color White
Write-ColorOutput "数据库管理工具: http://localhost:8083" -Color White

# 显示使用说明
Write-ColorOutput "\n使用说明:" -Color Yellow
Write-ColorOutput "1. 查看服务状态: docker compose -f $composeFileName ps" -Color White
Write-ColorOutput "2. 查看日志: docker compose -f $composeFileName logs -f" -Color White
Write-ColorOutput "3. 停止服务: docker compose -f $composeFileName down" -Color White
Write-ColorOutput "4. 重新部署: 再次运行此脚本" -Color White

# 执行健康检查
Write-ColorOutput "\n执行健康检查..." -Color Yellow
Start-Sleep -Seconds 10
try {
    $psOutput = docker compose -f $composeFile ps
    if ($psOutput -match "healthy") {
        Write-ColorOutput "所有服务健康检查通过！" -Color Green
    } else {
        Write-ColorOutput "部分服务可能尚未完全启动，请稍后再检查" -Color Yellow
    }
} catch {
    Write-ColorOutput "健康检查失败: $_" -Color Yellow
}

Write-ColorOutput "\n部署脚本执行完成！" -Color Green