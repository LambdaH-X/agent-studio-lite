#!/usr/bin/env pwsh

# Agent Studio Lite 生产环境一键部署脚本（仅支持Windows环境）

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
$composeFile = "docker-compose.prod.yml"
$composeFileName = Split-Path -Path $composeFile -Leaf
$env = "production"
$dryRun = $false

# 显示脚本信息和警告
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "     Agent Studio Lite 部署脚本     " -Color Green
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "部署环境: 生产环境" -Color Magenta
Write-ColorOutput "Docker Compose文件: $composeFileName" -Color Yellow
Write-ColorOutput "操作系统: Windows" -Color Yellow

# 生产环境警告
Write-ColorOutput "\n⚠️  警告：您正在部署到生产环境！⚠️" -Color Red
Write-ColorOutput "此操作将影响生产服务，请确保已备份重要数据。" -Color Red
Write-ColorOutput "请确认您已完成所有必要的准备工作。" -Color Red

# 确认是否继续
Write-ColorOutput "\n是否继续部署到生产环境？(y/n): " -Color Yellow -NoNewline
$confirmation = Read-Host
if ($confirmation -notmatch "^[yY]$") {
    Write-ColorOutput "部署已取消" -Color Yellow
    exit 0
}

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

# 检查.env文件是否存在
if (-not (Test-Path ".env")) {
    Write-ColorOutput "警告：未找到.env文件，可能需要配置环境变量" -Color Yellow
    Write-ColorOutput "请确保docker-compose.prod.yml中引用的所有环境变量已正确配置" -Color Yellow
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
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -ne 0) {
            Write-ColorOutput "命令执行失败，退出码: $exitCode" -Color Red
            
            # 生产环境下的错误处理
            if (-not $dryRun) {
                Write-ColorOutput "\n⚠️  生产环境部署失败，请检查错误信息并解决问题后再试。" -Color Red
                Write-ColorOutput "建议在重试前检查配置文件和环境设置。" -Color Red
                
                # 询问是否要查看日志
                Write-ColorOutput "\n是否查看服务日志？(y/n): " -Color Yellow -NoNewline
                $viewLogs = Read-Host
                if ($viewLogs -match "^[yY]$") {
                    Execute-Command "docker compose -f \"$composeFile\" logs --tail=50" ""
                }
            }
            
            return $exitCode
        }
        
        return $exitCode
    } catch {
        Write-ColorOutput "命令执行失败: $_" -Color Red
        return 1
    }
}

# 清理旧的容器和网络（可选）
Write-ColorOutput "\n是否清理旧的服务？(y/n): " -Color Yellow -NoNewline
$cleanOld = Read-Host
if ($cleanOld -match "^[yY]$") {
    Write-ColorOutput "[2/5] 清理旧的服务..." -Color Yellow
    Execute-Command "docker compose -f \"$composeFile\" down --remove-orphans" "停止并移除现有服务..."
} else {
    Write-ColorOutput "跳过清理旧服务..." -Color Yellow
}

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
Write-ColorOutput "等待20秒让服务初始化..." -Color Yellow
Start-Sleep -Seconds 20
Execute-Command "docker compose -f \"$composeFile\" ps" "显示服务状态..."

# 显示服务状态
Write-ColorOutput "\n========================================" -Color Green
Write-ColorOutput "服务部署完成！" -Color Green
Write-ColorOutput "========================================" -Color Green
Write-ColorOutput "环境: 生产环境" -Color Magenta
Write-ColorOutput "Docker Compose文件: $composeFileName" -Color Yellow

# 显示访问地址（根据docker-compose.prod.yml中的端口配置）
Write-ColorOutput "\n服务访问地址:" -Color White
Write-ColorOutput "前端地址: http://localhost" -Color White  # 生产环境通常使用默认80端口
Write-ColorOutput "后端API: http://localhost:8082" -Color White

# 显示使用说明
Write-ColorOutput "\n使用说明:" -Color Yellow
Write-ColorOutput "1. 查看服务状态: docker compose -f $composeFileName ps" -Color White
Write-ColorOutput "2. 查看日志: docker compose -f $composeFileName logs -f" -Color White
Write-ColorOutput "3. 停止服务: docker compose -f $composeFileName down" -Color White
Write-ColorOutput "4. 重新部署: 再次运行此脚本" -Color White

# 执行健康检查
Write-ColorOutput "\n执行健康检查..." -Color Yellow
Start-Sleep -Seconds 15
try {
    $psOutput = docker compose -f $composeFile ps
    if ($psOutput -match "healthy") {
        Write-ColorOutput "所有服务健康检查通过！" -Color Green
    } else {
        Write-ColorOutput "部分服务可能尚未完全启动，请稍后再检查" -Color Yellow
        Write-ColorOutput "建议执行以下命令查看详细日志:" -Color Yellow
        Write-ColorOutput "docker compose -f $composeFileName logs --tail=50" -Color Yellow
    }
} catch {
    Write-ColorOutput "健康检查失败: $_" -Color Yellow
}

# 生产环境部署完成提醒
Write-ColorOutput "\n========================================" -Color Magenta
Write-ColorOutput "生产环境部署已完成！" -Color Magenta
Write-ColorOutput "请立即验证服务是否正常运行！" -Color Magenta
Write-ColorOutput "========================================" -Color Magenta