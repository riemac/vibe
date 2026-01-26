---
name: annotations
description: 代码与配置文件的注释规范。面向科研人员（非专业软件工程师），确保代码、脚本、配置文件可理解和可维护。覆盖：(1) Python 代码（函数/类/行内注释）；(2) Bash/Shell 脚本；(3) Docker/Dockerfile；(4) ROS2 launch/config；(5) YAML/TOML/JSON 配置。核心原则：解释"为什么"而非"是什么"，标注科研相关约定（单位、坐标系、论文来源）。
---

# Annotations（注释规范）

面向科研人员的注释规范：让代码、脚本、配置对"非专业软件工程师"可理解。

## 核心原则

1. **解释"为什么"**：设计动机 > 代码描述
2. **标注科研约定**：单位、坐标系、论文引用、消融来源
3. **面向科研人员**：不假设读者有深厚工程背景

## 场景选择

| 场景 | 文件类型 | 典型示例 | 详细指南 |
|------|----------|----------|----------|
| **Python 代码** | `.py` | 算法、模型、工具函数 | [references/python.md](references/python.md) |
| **Shell/Bash** | `.sh`, `.bash` | 训练脚本、环境安装 | [references/shell.md](references/shell.md) |
| **Docker** | `Dockerfile`, `compose.yaml` | 容器构建、服务编排 | [references/docker.md](references/docker.md) |
| **ROS2** | `launch.py`, `*.yaml` | 机器人系统配置 | [references/ros2.md](references/ros2.md) |
| **配置文件** | `.yaml`, `.toml`, `.json` | 训练配置、超参数 | [references/config.md](references/config.md) |

## 行内注释规范

行内注释用于解释非显而易见的代码行，不需要完整的 docstring 结构。

### 何时需要行内注释

- 魔法数字：`batch_size = 32  # 消融实验最优值，见 Fig.3`
- 非显然逻辑：`# 这里用 += 而非 = 是因为需要累积梯度`
- 单位/约定：`distance = 0.05  # 单位：米，阈值来自 [Smith 2023]`
- 临时方案：`# HACK: 绕过 Isaac 的 bug，待 v2.0 修复后移除`
- 待办事项：`# TODO(author): 添加多进程支持`

### 行内注释模式

```python
# === Section: 功能区块名 ===
code_block

value = 42  # <含义>。来源: <论文/实验>。
# 为什么 <决策>: <原因>
tricky_code

# TODO(<author>): <待完成>
# HACK: <临时方案>，待 <条件> 后移除
# WARN: <使用注意>
```

## 快速示例

### Python 函数

```python
def compute_rotation_error(q_pred: Tensor, q_tgt: Tensor) -> Tensor:
    """计算旋转角度误差。

    Args:
        q_pred: 预测四元数。Shape: (N, 4)。Convention: wxyz, normalized。
        q_tgt: 目标四元数。Shape: (N, 4)。

    Returns:
        误差角度（弧度）。Range: [0, π]。

    Notes:
        公式: θ = 2·arccos(|q_Δ,w|)。参考 [Huynh 2009] Eq. (5)。
    """
```

### Bash 脚本

```bash
#!/bin/bash
# 训练脚本：启动 DRO-Grasp 模型训练
# 依赖: conda 环境 env_dro，需先 `conda activate env_dro`
# 用法: ./train.sh [config_name]

# === 环境检查 ===
# 确保 CUDA 可用，否则训练会退回 CPU（极慢）
if ! nvidia-smi &> /dev/null; then
    echo "Error: CUDA not available" && exit 1
fi

BATCH_SIZE=32   # 消融实验最优，见论文 Table 2
LR=1e-4         # 初始学习率，warmup 后调整
```

### Dockerfile

```dockerfile
# DRO-Grasp 推理环境
# 基础镜像选择理由: 需要 CUDA 12.x + PyTorch 兼容

FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
# 为什么用 runtime 而非 devel: 推理不需要编译器，镜像更小

WORKDIR /app
# 依赖安装分离：利用 Docker 缓存，requirements 变化时不重建整个镜像
COPY requirements.txt .
RUN pip install -r requirements.txt
```

### ROS2 Launch

```python
# Isaac Gym + ROS2 集成启动文件
# 功能: 启动仿真环境 + 抓取节点
# 依赖: ros2 humble, isaac_ros_common

def generate_launch_description():
    # 仿真频率 60Hz: Isaac Gym 物理步长要求
    sim_hz = 60
    
    return LaunchDescription([
        # 先启动仿真，等待 5s 让场景加载完成
        ...
    ])
```

### YAML 配置

```yaml
# DRO-Grasp 训练配置
# 修改前请阅读: doc/config_guide.md

# === 模型架构 ===
model:
  hidden_dim: 256   # 消融实验最优，见 Fig.4
  num_layers: 4     # 更多层 → 更慢但更准，按需调整

# === 训练参数 ===
train:
  batch_size: 32    # 显存限制，24GB GPU 最大 64
  lr: 1e-4          # 配合 cosine schedule 使用
  # 跨字段约束: epochs × steps_per_epoch ≈ 50k 总步数
```

## Review 检查清单

- [ ] 魔法数字有来源说明
- [ ] 非显然逻辑有"为什么"注释
- [ ] 科研相关代码有单位/坐标系/论文引用
- [ ] 临时方案有 HACK/TODO 标记
- [ ] 配置文件有字段说明和跨字段约束
- [ ] Bash 脚本有用法说明和依赖声明

## 详细指南与模板

- [references/python.md](references/python.md)：Python 代码（docstring + 行内）
- [references/shell.md](references/shell.md)：Bash/Shell 脚本
- [references/docker.md](references/docker.md)：Docker/Compose
- [references/ros2.md](references/ros2.md)：ROS2 launch 和配置
- [references/config.md](references/config.md)：YAML/TOML/JSON 配置
- [references/templates.md](references/templates.md)：可复用模板
