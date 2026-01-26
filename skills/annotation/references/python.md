# Python 代码注释规范

覆盖 docstring（函数/类/模块）和行内注释两类场景。

## Docstring 规范

使用 Google 风格：Args / Returns / Raises / Notes。

### 科研代码特殊要求

#### 数学符号映射

```python
def forward(self, x: Tensor, cond: Tensor) -> Tensor:
    """扩散模型前向传播。

    Notes:
        符号映射（对应论文 Sec. 3.2）：
            - x     → x_t（当前时间步的噪声样本）
            - cond  → c（条件向量）
            - out   → ε_θ(x_t, t, c)（预测的噪声）
    """
```

#### 坐标系与单位

| 类型 | 约定示例 |
|------|----------|
| 坐标系 | `Frame: robot base / world / object / camera` |
| 四元数 | `Convention: wxyz / xyzw` |
| 长度单位 | `Unit: meters / millimeters` |
| 角度单位 | `Unit: radians / degrees` |

```python
def transform_to_world(
    pos_obj: Tensor,     # Shape: (N, 3). Frame: object. Unit: meters.
    T_world_obj: Tensor  # Shape: (N, 4, 4). Homogeneous transform.
) -> Tensor:
    """将物体坐标系下的点转换到世界坐标系。"""
```

#### 论文引用

```python
Notes:
    参考：
        - [Huynh 2009] Metrics for 3D Rotations, Eq. (5)
        - 本实现与原论文差异：使用 geodesic 距离而非欧氏距离
```

### 工程代码特殊要求

#### 契约式注释

```python
def normalize_point_cloud(points: np.ndarray) -> np.ndarray:
    """将点云归一化到单位球内。

    Contracts:
        - Pre: points 至少有 1 个点
        - Post: 所有点范数 <= 1.0
        - Post: 质心在原点
    """
```

#### 错误处理

```python
Raises:
    FileNotFoundError: 文件路径不存在。
    ValueError: 文件格式不支持（仅支持 .ply, .pcd）。
```

#### 边界条件

```python
Notes:
    边界情况：
        - 空输入：返回空张量（不抛异常）
        - NaN/Inf：会传播，调用方需预处理
```

## 行内注释规范

### 何时添加

- **魔法数字**：`batch_size = 32  # 消融实验最优，见 Fig.3`
- **单位/约定**：`dist = 0.05  # 单位: 米，阈值来自 [Smith 2023]`
- **非显然逻辑**：`# 这里用 += 而非 = 是因为需要累积梯度`
- **临时方案**：`# HACK: 绕过 Isaac bug，待 v2.0 后移除`
- **待办事项**：`# TODO(author): 添加多进程支持`

### 区块注释

```python
# === Section: 数据预处理 ===

# === Section: 模型前向 ===

# === Section: 损失计算 ===
```

### 性能注释

```python
# 缓存变换矩阵，节省 ~5ms/frame
self._cached_transform = self._compute_transform()

# O(N log N) 排序
sorted_indices = np.argsort(distances)
```

## 模板

### 科研函数

```python
def algorithm_function(input: Tensor, param: float) -> Tensor:
    """<一句话描述>

    Args:
        input: <含义>。Shape: <...>。Convention/Unit: <...>。
        param: <含义>。Range: <...>。

    Returns:
        <含义>。Shape: <...>。

    Notes:
        研究动机：<为什么需要这个函数>
        
        数学推导：<公式>
        
        符号映射：
            - input → <论文符号>
            
        参考：[Author YYYY] Title, Eq. (X)
    """
```

### 工程函数

```python
def utility_function(input: T, option: bool = False) -> R:
    """<一句话描述>

    Args:
        input: <含义>。Constraints: <...>。
        option: <含义>。Default: <值>。

    Returns:
        <含义>。Guarantees: <...>。

    Raises:
        <ErrorType>: <条件>。

    Contracts:
        - Pre: <前置条件>
        - Post: <后置条件>

    Notes:
        边界情况：<...>
    """
```
