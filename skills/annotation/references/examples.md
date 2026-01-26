# 注释示例集

综合示例，覆盖各场景。

## Python 示例

### 科研代码：扩散模型

```python
def denoise_step(
    x_t: torch.Tensor,
    t: torch.Tensor,
    model: nn.Module,
    noise_schedule: NoiseSchedule,
) -> torch.Tensor:
    """DDPM 单步去噪。

    Args:
        x_t: 当前噪声样本。Shape: (B, C, H, W)。
        t: 时间步。Shape: (B,)。Range: [0, T-1]。
        model: 噪声预测网络 ε_θ。
        noise_schedule: 噪声调度器，包含 α_t, ᾱ_t 等。

    Returns:
        去噪后的样本 x_{t-1}。Shape: (B, C, H, W)。

    Notes:
        数学推导（DDPM Eq. 11）：
            μ_θ(x_t, t) = (1/√α_t) · (x_t - β_t/√(1-ᾱ_t) · ε_θ(x_t, t))
            x_{t-1} = μ_θ + σ_t · z, 其中 z ~ N(0, I)

        符号映射：
            - x_t  → x_t（公式中的噪声样本）
            - model(x_t, t) → ε_θ(x_t, t)（预测噪声）
            
        参考：
            - [Ho et al. 2020] DDPM, Algorithm 2
    """
    # 预测噪声
    eps_pred = model(x_t, t)
    
    # 计算均值（Eq. 11）
    alpha_t = noise_schedule.alpha[t]
    alpha_bar_t = noise_schedule.alpha_bar[t]
    beta_t = noise_schedule.beta[t]
    
    # 注意：这里用 rsqrt 而非 1/sqrt，数值更稳定
    mean = torch.rsqrt(alpha_t) * (x_t - beta_t / torch.sqrt(1 - alpha_bar_t) * eps_pred)
    
    # 添加噪声（t=0 时不加）
    if t.min() > 0:
        sigma_t = torch.sqrt(beta_t)
        noise = torch.randn_like(x_t)
        return mean + sigma_t * noise
    else:
        return mean
```

### 工程代码：点云采样

```python
def farthest_point_sample(points: np.ndarray, n_samples: int) -> np.ndarray:
    """最远点采样，保持点云几何覆盖。

    Args:
        points: 输入点云。Shape: (N, 3)。
        n_samples: 采样点数。Must be in [1, N]。

    Returns:
        采样索引。Shape: (n_samples,)。

    Raises:
        ValueError: n_samples > N 或 < 1。

    Contracts:
        - Pre: points.shape[0] >= n_samples
        - Post: 返回索引唯一

    Notes:
        时间: O(n_samples × N)
        边界：n_samples == N 时返回 range(N)
    """
```

## Bash 示例

```bash
#!/bin/bash
# train.sh: DRO-Grasp 训练脚本
#
# 功能: 配置环境 + 启动训练
# 依赖: conda env_dro, nvidia-driver
# 用法: ./train.sh [config] [--resume]

set -euo pipefail

# ==============================================================================
# 配置
# ==============================================================================

CONFIG=${1:-default}
BATCH_SIZE=32   # 消融最优，Table 2
LR=1e-4

# ==============================================================================
# 环境检查
# ==============================================================================

# CUDA 检查
if ! nvidia-smi &> /dev/null; then
    echo "Error: CUDA not available" >&2
    exit 1
fi

# ==============================================================================
# 启动训练
# ==============================================================================

# -u: 禁用缓冲，日志实时可见
python -u train.py --config "configs/${CONFIG}.yaml"
```

## Dockerfile 示例

```dockerfile
# DRO-Grasp 训练镜像
# 
# 基础镜像: nvidia/cuda:12.1
# 构建: docker build -t dro-grasp:train .

FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
# 选 runtime：推理不需编译器，镜像更小

ENV PYTHONUNBUFFERED=1

# 依赖分层
COPY requirements.txt /app/
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
CMD ["python", "train.py"]
```

## ROS2 示例

```python
#!/usr/bin/env python3
"""grasp_pipeline.launch.py - 抓取流水线

功能: 启动相机 + 抓取规划
依赖: realsense2_camera, dro_grasp
"""

from launch import LaunchDescription
from launch.actions import TimerAction
from launch_ros.actions import Node

def generate_launch_description():
    camera = Node(
        package='realsense2_camera',
        executable='realsense2_camera_node',
        parameters=[{'enable_pointcloud': True}],
    )
    
    # 延迟 3s：等相机初始化
    planner = TimerAction(
        period=3.0,
        actions=[Node(
            package='dro_grasp',
            executable='grasp_planner',
            parameters=[{'confidence_threshold': 0.7}],
        )],
    )
    
    return LaunchDescription([camera, planner])
```

## YAML 示例

```yaml
# train.yaml - DRO-Grasp 配置
# 修改前检查显存限制

model:
  hidden_dim: 256   # 消融最优，Fig.4
  num_layers: 4

train:
  batch_size: 32    # 24GB GPU。12GB → 16
  lr: 1e-4
  # 跨字段约束: batch × accum = effective
  gradient_accumulation: 2
```
