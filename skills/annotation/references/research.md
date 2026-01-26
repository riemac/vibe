# 科研代码注释规范

面向算法实现、模型定义、损失函数等科研核心代码。

## 核心要求

### 1. 数学符号与代码变量映射

在 Notes 中明确论文符号与代码变量的对应关系：

```python
def forward(self, x: torch.Tensor, cond: torch.Tensor) -> torch.Tensor:
    """扩散模型前向传播。

    Notes:
        符号映射（对应论文 Sec. 3.2）：
            - x     → x_t（当前时间步的噪声样本）
            - cond  → c（条件向量）
            - out   → ε_θ(x_t, t, c)（预测的噪声）
    """
```

### 2. 坐标系与单位约定

**必须标注的内容**：

| 类型 | 约定 | 示例 |
|------|------|------|
| 坐标系 | world / object / robot / camera | `Frame: robot base` |
| 四元数 | wxyz / xyzw | `Convention: wxyz` |
| 旋转矩阵 | row-major / column-major | `Layout: row-major` |
| 长度单位 | 米 / 毫米 | `Unit: meters` |
| 角度单位 | 弧度 / 度 | `Unit: radians` |

```python
def transform_to_world(
    pos_obj: torch.Tensor,  # Shape: (N, 3). Frame: object. Unit: meters.
    T_world_obj: torch.Tensor  # Shape: (N, 4, 4). Homogeneous transform.
) -> torch.Tensor:
    """将物体坐标系下的点转换到世界坐标系。

    Returns:
        pos_world: 世界坐标系下的点。Shape: (N, 3). Frame: world. Unit: meters.
    """
```

### 3. 论文引用格式

```python
Notes:
    参考文献：
        - [Author YYYY] Paper title, Eq. (X) / Sec. Y / Algorithm Z
        - 本实现与原论文差异：...
```

### 4. 数学推导

使用 LaTeX 风格或 Unicode 符号：

```python
Notes:
    数学推导：
        损失函数 L = E_t[||ε - ε_θ(x_t, t)||²]
        
        其中：
            - ε ~ N(0, I) 是真实噪声
            - x_t = √(ᾱ_t)·x_0 + √(1-ᾱ_t)·ε
```

## 模板

```python
def algorithm_function(input: Tensor, param: float) -> Tensor:
    """<一句话描述功能>

    Args:
        input: <含义>。Shape: <...>。Convention/Frame/Unit: <...>。
        param: <含义>。Range: <...>。

    Returns:
        <含义>。Shape: <...>。Convention/Frame/Unit: <...>。

    Notes:
        研究动机：
            <为什么需要这个函数，解决什么问题>

        数学推导：
            <公式或伪代码>

        符号映射：
            - <代码变量> → <论文符号>

        参考：
            - [Author YYYY] Title, Eq./Sec./Algo.

        与论文差异：
            - <如有>

        边界情况：
            - <特殊输入如何处理>
    """
```

## 反模式

❌ 仅重述代码：`# 计算四元数乘法`  
✅ 解释动机：`# 将抓取姿态从物体坐标系转换到世界坐标系`

❌ 隐含坐标系：`pos = transform(pos)`  
✅ 显式标注：`pos_world = transform(pos_obj)  # object → world`

❌ 魔法数字无解释：`threshold = 0.01`  
✅ 标注来源：`threshold = 0.01  # 消融实验确定，见 Table 3`
