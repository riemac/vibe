# 工程代码注释规范

面向工具函数、数据加载、基础设施等工程代码。

## 核心要求

### 1. 契约式注释

明确前置条件（Pre）、后置条件（Post）、不变量（Invariant）：

```python
def normalize_point_cloud(points: np.ndarray) -> np.ndarray:
    """将点云归一化到单位球内。

    Args:
        points: 输入点云。Shape: (N, 3)。

    Returns:
        归一化后的点云。Shape: (N, 3)。

    Contracts:
        - Pre: points 至少有 1 个点
        - Post: 所有点的范数 <= 1.0
        - Post: 质心在原点
    """
```

### 2. 错误处理

必须标注所有 Raises 及其触发条件：

```python
Raises:
    FileNotFoundError: 文件路径不存在。
    ValueError: 文件格式不支持（仅支持 .ply, .pcd）。
    RuntimeError: 文件损坏或解析失败。
```

### 3. 边界条件

显式说明边界情况的处理方式：

```python
Notes:
    边界情况：
        - 空输入：返回空张量（不抛异常）
        - 单点输入：中心化后该点位于原点
        - NaN/Inf：会传播，调用方需预处理
```

### 4. 性能注释

标注缓存、预计算、复杂度：

```python
# 缓存变换矩阵，避免每帧重复计算（节省 ~5ms/frame）
self._cached_transform = self._compute_transform()

# O(N log N) 排序，N 为点数
sorted_indices = np.argsort(distances)
```

### 5. 副作用标注

函数有副作用时必须在 docstring 中声明：

```python
def update_buffer(self, data: np.ndarray) -> None:
    """更新内部缓冲区。

    Side Effects:
        - 修改 self._buffer
        - 增加 self._count
    """
```

## 模板

```python
def utility_function(input: T, option: bool = False) -> R:
    """<一句话描述功能>

    Args:
        input: <含义>。Constraints: <类型/范围/格式>。
        option: <含义>。Default: <值>。

    Returns:
        <含义>。Guarantees: <后置条件>。

    Raises:
        <ErrorType>: <触发条件>。

    Contracts:
        - Pre: <前置条件>
        - Post: <后置条件>
        - Invariant: <不变量>（如适用）

    Notes:
        边界情况：
            - <特殊输入如何处理>

        性能：
            - 时间复杂度：O(...)
            - 空间复杂度：O(...)

        Side Effects（如有）：
            - <副作用描述>
    """
```

## 实现注释规范

```python
# === Section: Data Loading ===

# 为什么用 mmap：大文件时避免一次性加载到内存
data = np.load(path, mmap_mode='r')

# TODO(author): 临时 workaround，等上游修复后移除
# Issue: https://github.com/xxx/yyy/issues/123
result = hacky_fix(result)

# PERF: 预计算查找表，将 O(n) 查询降到 O(1)
self._lookup_table = self._build_lookup()

# WARN: 这里假设输入已排序，否则结果错误
mid = binary_search(sorted_array, target)
```

## 反模式

❌ 无错误处理说明：调用方不知道何时会抛异常  
✅ 完整的 Raises 列表

❌ 隐含副作用：`update()` 修改了全局状态但未说明  
✅ Side Effects 显式声明

❌ 复杂度未标注：调用方不知道性能特性  
✅ 在 Notes 中说明时间/空间复杂度
