# 配置代码注释规范

面向配置类、超参数定义、YAML/TOML 解析等配置相关代码。

## 核心要求

### 1. 超参数来源

每个超参数必须说明其来源（消融实验、论文、经验值）：

```python
@dataclass
class TrainingConfig:
    """训练配置。

    Attributes:
        lr: 学习率。Default: 1e-4。来源：消融实验 Table 2。
        batch_size: 批大小。Default: 64。来源：显存限制（24GB GPU）。
        warmup_steps: 预热步数。Default: 1000。来源：[Vaswani 2017] 建议。
    """
    lr: float = 1e-4
    batch_size: int = 64
    warmup_steps: int = 1000
```

### 2. 有效范围

标注参数的有效范围和典型值：

```python
Attributes:
    temperature: 采样温度。Range: (0, +∞)。Typical: 0.1~1.0。
        - < 0.5: 保守采样，多样性低
        - > 1.0: 激进采样，可能不稳定
    dropout: Dropout 概率。Range: [0, 1)。Default: 0.1。
```

### 3. 跨字段约束

当多个字段之间存在约束关系时必须说明：

```python
Notes:
    跨字段约束：
        - num_workers 应 <= CPU 核心数
        - batch_size * num_workers 应 < 可用内存
        - 如果 use_amp=True，则 dtype 必须兼容混合精度
```

### 4. 默认值理由

解释为什么选择这个默认值：

```python
Attributes:
    num_points: 采样点数。Default: 1024。
        理由：平衡精度与速度。消融实验显示 1024→2048 精度提升 <1%，
        但推理时间增加 40%。
```

## 模板

### Dataclass 配置

```python
@dataclass
class ComponentConfig:
    """<组件名>配置。

    Attributes:
        <param1>: <含义>。
            Default: <值>。
            Range: <有效范围>。
            来源: <消融实验/论文/经验>。

        <param2>: <含义>。
            Default: <值>。
            Typical: <典型使用范围>。
            注意: <使用时的注意事项>。

    Notes:
        跨字段约束：
            - <约束1>
            - <约束2>

        配置示例：
            - 快速实验：<推荐配置>
            - 生产部署：<推荐配置>
    """
```

### YAML 配置注释

```yaml
# === Training Configuration ===

learning_rate: 1e-4  # 来源：消融实验 Table 2。Range: [1e-5, 1e-3]
batch_size: 64       # 受 GPU 显存限制（24GB）。增大可提升收敛速度
num_epochs: 100      # 典型收敛需 50-100 epochs

# 跨字段约束：batch_size * gradient_accumulation 应保持一致
gradient_accumulation: 4  # 模拟 batch_size=256 的效果
```

## 消融实验引用格式

```python
# 来源：消融实验
# | 参数值 | 精度 (%) | 推理时间 (ms) |
# |--------|----------|---------------|
# | 512    | 92.3     | 12            |
# | 1024   | 94.1     | 18            | ← 选择
# | 2048   | 94.5     | 31            |
num_points: int = 1024
```

## 反模式

❌ 无来源的默认值：`lr = 1e-4`  
✅ 标注来源：`lr = 1e-4  # 消融实验确定`

❌ 无范围说明：不知道什么值是合理的  
✅ 标注 Range 和 Typical

❌ 隐含跨字段约束：配置不一致导致运行时错误  
✅ 在 Notes 中显式说明约束关系
