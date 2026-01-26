# Annotation Templates

可复用的注释模板，按场景分类。

## 通用函数模板

```python
def function_name(arg1: Type1, arg2: Type2 = default) -> ReturnType:
    """<一句话描述：动词开头>

    Args:
        arg1: <含义>。<约束：Shape/Range/Unit/Convention>。
        arg2: <含义>。Default: <值>。<约束>。

    Returns:
        <含义>。<约束：Shape/Range/Unit/Convention>。

    Raises:
        <ErrorType>: <触发条件>。
    """
```

## 科研代码模板

### 算法函数

```python
def algorithm_function(input: Tensor, param: float) -> Tensor:
    """<一句话描述>

    Args:
        input: <含义>。Shape: (B, N, D)。Convention: <...>。
        param: <含义>。Range: <...>。

    Returns:
        <含义>。Shape: (B, M)。Unit: <...>。

    Notes:
        研究动机：
            <为什么需要这个函数>

        数学推导：
            <公式，使用 LaTeX 或 Unicode>

        符号映射：
            - input → <论文符号>
            - output → <论文符号>

        参考：
            - [Author YYYY] Title, Eq. (X) / Sec. Y

        与论文差异（如有）：
            - <差异说明>
    """
```

### 神经网络模块

```python
class ModuleName(nn.Module):
    """<模块功能描述>

    <模块在整体架构中的角色>

    Attributes:
        attr1: <含义>。
        attr2: <含义>。

    Notes:
        架构参考：
            - [Author YYYY] Fig. X / Sec. Y

        符号映射：
            - self.xxx → <论文符号>

        输入输出约定：
            - 输入：<Shape, Convention>
            - 输出：<Shape, Convention>
    """

    def forward(self, x: Tensor) -> Tensor:
        """前向传播。

        Args:
            x: <含义>。Shape: <...>。

        Returns:
            <含义>。Shape: <...>。
        """
```

## 工程代码模板

### 工具函数

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
        边界情况：
            - <特殊输入>: <处理方式>

        性能：
            - 时间: O(...)
            - 空间: O(...)
    """
```

### 类

```python
class ClassName:
    """<类的职责>

    <在系统中的角色>

    Attributes:
        attr1: <含义>。<生命周期>。
        attr2: <含义>。<约束>。

    Invariants:
        - <不变量1>
        - <不变量2>

    Thread Safety:
        <线程安全说明>（如适用）
    """
```

## 配置模板

### Dataclass

```python
@dataclass
class ComponentConfig:
    """<组件名>配置。

    Attributes:
        param1: <含义>。
            Default: <值>。Range: <...>。
            来源: <消融实验/论文/经验>。

        param2: <含义>。
            Default: <值>。Typical: <...>。

    Notes:
        跨字段约束：
            - <约束描述>

        推荐配置：
            - 场景A: <配置>
            - 场景B: <配置>
    """
    param1: float = 1.0
    param2: int = 100
```

### YAML 注释

```yaml
# === Section Name ===

param1: value1  # <含义>。Range: [min, max]。来源: <...>
param2: value2  # <含义>。Options: [opt1, opt2]。Default 理由: <...>

# 跨字段约束：param1 和 param2 需满足 <条件>
```

## 实现注释模板

```python
# === Section: <功能区块名> ===

# 为什么 <决策>: <原因>
code_line

# TODO(<author>): <待完成事项>
# Issue: <链接>（如有）

# PERF: <性能相关说明>

# WARN: <使用注意事项>

# HACK: <临时方案说明>，待 <条件> 后移除
```
