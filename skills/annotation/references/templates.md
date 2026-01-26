# 注释模板

可复用的注释模板。

## Python

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
        研究动机：<为什么需要>
        
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
        边界：<...>
    """
```

### 行内注释

```python
# === Section: <区块名> ===

value = 42  # <含义>。来源: <论文/实验>。

# 为什么 <决策>: <原因>
tricky_code

# TODO(<author>): <待完成>
# HACK: <临时方案>，待 <条件> 后移除
```

## Bash

### 脚本头

```bash
#!/bin/bash
# <script_name>: <功能>
#
# 功能: <详细说明>
# 依赖: <环境要求>
# 用法: <调用方式>
# 示例: <具体示例>

set -euo pipefail
```

### 区块

```bash
# ==============================================================================
# <区块名>
# ==============================================================================

VAR=value  # <说明>
```

## Dockerfile

### 文件头

```dockerfile
# <镜像名> - <功能>
# 
# 基础镜像: <选择理由>
# 构建: docker build -t <tag> .
# 运行: docker run <options> <tag>

FROM <base-image>
# 选择理由: <...>
```

### 指令注释

```dockerfile
# === 环境配置 ===
ENV VAR=value  # <说明>

# === 依赖安装 ===
# 分层：利用缓存
COPY requirements.txt .
RUN pip install -r requirements.txt

# === 代码复制 ===
COPY . /app
```

## ROS2

### Launch 文件

```python
#!/usr/bin/env python3
"""<文件名> - <功能>

功能: <说明>
依赖: <包名>
用法: ros2 launch <pkg> <file> [args]
"""

from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    # === 参数 ===
    
    # === 节点 ===
    node = Node(
        package='pkg',
        executable='exec',
        parameters=[{'key': 'value'}],  # <说明>
    )
    
    return LaunchDescription([node])
```

### 配置文件

```yaml
# <文件名> - <功能>
# 
# 适用节点: <node_name>

/node_name:
  ros__parameters:
    # === Section ===
    param: value  # <含义>。来源: <...>。
```

## YAML 配置

```yaml
# <配置名> - <功能>
# 修改说明: <注意事项>

# === Section ===
param: value    # <含义>。Range: <...>。来源: <...>。

# 跨字段约束: <描述>
```
