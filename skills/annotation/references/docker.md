# Docker 注释规范

覆盖 Dockerfile 和 docker-compose.yaml。

## Dockerfile 注释

### 文件头

```dockerfile
# <镜像名称> - <功能描述>
# 
# 用途: <典型使用场景>
# 基础镜像选择理由: <为什么选这个>
# 构建: docker build -t <tag> .
# 运行: docker run <options> <tag>
```

### 基础镜像选择

```dockerfile
# 选择 runtime 而非 devel：推理不需要编译器，镜像更小（节省 ~2GB）
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# 使用 slim 变体：只包含 Python 运行时，无编译工具
FROM python:3.10-slim
```

### 多阶段构建

```dockerfile
# === Stage 1: 构建阶段 ===
# 包含编译工具，用于构建 wheel
FROM python:3.10 AS builder
# ...

# === Stage 2: 运行阶段 ===
# 只复制编译好的产物，最小化镜像体积
FROM python:3.10-slim AS runtime
COPY --from=builder /app/dist/*.whl .
```

### 依赖安装

```dockerfile
# 依赖安装分层：利用 Docker 缓存
# requirements.txt 不变时，不重新安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 再复制代码（代码变化频繁，放后面）
COPY . .
```

### 环境变量

```dockerfile
# 禁用 Python 输出缓冲，确保日志实时可见
ENV PYTHONUNBUFFERED=1

# 禁止生成 .pyc 文件，减少镜像体积
ENV PYTHONDONTWRITEBYTECODE=1

# CUDA 架构，针对 RTX 30/40 系列优化
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.9"
```

### RUN 指令优化

```dockerfile
# 合并 RUN 减少镜像层数
# 最后清理 apt 缓存，减少镜像体积
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
    && rm -rf /var/lib/apt/lists/*
```

## docker-compose.yaml 注释

### 服务说明

```yaml
services:
  # === 训练服务 ===
  # GPU 训练容器，挂载数据和输出目录
  train:
    image: dro-grasp:train
    # GPU 配置：使用全部可用 GPU
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  # === 推理服务 ===
  # 无状态服务，可水平扩展
  infer:
    image: dro-grasp:infer
```

### 卷挂载

```yaml
volumes:
  # 数据目录：只读，防止训练过程误修改原始数据
  - ./data:/app/data:ro
  
  # 输出目录：读写，存放 checkpoint 和日志
  - ./outputs:/app/outputs:rw
  
  # 缓存目录：HuggingFace 模型缓存，避免重复下载
  - ~/.cache/huggingface:/root/.cache/huggingface
```

### 网络配置

```yaml
networks:
  # 内部网络：服务间通信，不暴露到宿主机
  internal:
    driver: bridge
    internal: true
```

### 环境变量

```yaml
environment:
  # CUDA 设备选择，默认使用 GPU 0
  - CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}
  
  # 显存分配配置，减少碎片
  - PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
```

## 模板

### Dockerfile

```dockerfile
# <镜像名> - <功能>
# 
# 基础镜像: <选择理由>
# 构建: docker build -t <tag> .
# 运行: docker run <options> <tag>

FROM <base-image>

# === 环境配置 ===
ENV PYTHONUNBUFFERED=1

# === 依赖安装 ===
# 分层安装，利用缓存
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# === 代码复制 ===
COPY . /app
WORKDIR /app

# === 入口点 ===
CMD ["python", "main.py"]
```

### docker-compose.yaml

```yaml
# <项目名> Docker Compose 配置
# 
# 用法: docker compose up -d
# 服务说明: <概述各服务功能>

services:
  service_name:
    build: .
    # <服务配置说明>
    volumes:
      - ./data:/app/data  # <挂载说明>
    environment:
      - VAR=value  # <变量说明>
```
