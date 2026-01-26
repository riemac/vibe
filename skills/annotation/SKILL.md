---
name: annotations
description: 代码注释规范。覆盖科研/工程/配置三类场景，强制执行 Google Docstring + 契约式注释。科研场景记录研究动机、数学推导、论文引用；工程场景关注契约、边界条件、错误处理；配置场景标注超参数来源和有效范围。
---

# Annotations（代码注释规范）

统一的代码注释规范，覆盖所有 coding 场景。

## 通用原则

1. **Google Docstring 风格**：Args / Returns / Raises / Notes
2. **解释"为什么"而非"是什么"**：注释首先回答设计动机
3. **契约式**：明确前置条件、后置条件、不变量

## 场景选择

根据代码性质选择对应的注释规范：

| 场景 | 核心关注 | 典型代码 | 详细指南 |
|------|----------|----------|----------|
| **科研代码** | 数学推导、论文引用、实验动机 | 算法实现、模型定义、损失函数 | [references/research.md](references/research.md) |
| **工程代码** | 契约、边界条件、错误处理 | 工具函数、数据加载、基础设施 | [references/engineering.md](references/engineering.md) |
| **配置** | 超参数来源、消融依据、有效范围 | 配置类、YAML 解析 | [references/config.md](references/config.md) |

## 快速示例

### 科研代码

```python
def compute_rotation_error(q_pred: torch.Tensor, q_tgt: torch.Tensor) -> torch.Tensor:
    """计算预测与目标四元数之间的旋转角度误差。

    Args:
        q_pred: 预测四元数。Shape: (N, 4)。Convention: wxyz。Must be normalized。
        q_tgt: 目标四元数。Shape: (N, 4)。Convention: wxyz。Must be normalized。

    Returns:
        旋转角度误差（弧度）。Shape: (N,)。Range: [0, π]。

    Notes:
        数学推导：
            设 q_Δ = q_tgt⁻¹ ⊗ q_pred，则角度 θ = 2·arccos(|q_Δ,w|)
            
        参考：
            - Quaternion distance metrics, [Huynh 2009] Eq. (5)
    """
```

### 工程代码

```python
def load_point_cloud(path: str, num_points: int = 1024) -> np.ndarray:
    """从文件加载并采样点云。

    Args:
        path: 点云文件路径。Must exist。Supported: .ply, .pcd, .npy。
        num_points: 采样点数。Must be > 0。Default: 1024。

    Returns:
        采样后的点云。Shape: (num_points, 3)。单位: 米。

    Raises:
        FileNotFoundError: 文件不存在。
        ValueError: 不支持的文件格式或 num_points <= 0。

    Contracts:
        - Pre: path 指向有效的点云文件
        - Post: 返回的点云恰好有 num_points 个点
    """
```

## Review 检查清单

- [ ] 每个公共函数有完整 docstring（Args / Returns）
- [ ] 复杂算法有 Notes 说明（数学推导或论文引用）
- [ ] 魔法数字有注释解释来源
- [ ] 临时 hack 有 TODO 标记
- [ ] 单位和坐标系约定已明确（科研代码）
- [ ] 错误处理路径已覆盖（工程代码）

## 示例与模板

- [references/examples.md](references/examples.md)：综合示例
- [references/templates.md](references/templates.md)：可复用模板
