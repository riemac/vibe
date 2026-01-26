---
name: annotations
description: 代码和配置文件的注释规范。用于编写或审查代码时添加注释，确保科研人员（非专业软工）能理解代码逻辑和设计决策。
---

# Annotations（注释规范）

让代码、脚本、配置对"非专业软件工程师"可理解。

## 核心原则

1. **解释"为什么"**：设计动机 > 代码描述
2. **标注科研约定**：单位、坐标系、论文引用
3. **面向科研人员**：不假设读者有深厚工程背景

## 详细指南

按文件类型选择对应规范：

| 文件类型 | 详细指南 |
|----------|----------|
| Python `.py` | [references/python.md](references/python.md) |
| Bash `.sh` | [references/shell.md](references/shell.md) |
| Dockerfile | [references/docker.md](references/docker.md) |
| ROS2 launch/config | [references/ros2.md](references/ros2.md) |
| YAML/TOML/JSON | [references/config.md](references/config.md) |

更多示例：[references/examples.md](references/examples.md)  
可复用模板：[references/templates.md](references/templates.md)

## 行内注释

适用于所有语言：

```
value = 42  # <含义>。来源: <论文/实验>。

# 为什么 <决策>: <原因>
tricky_code

# TODO(<author>): <待完成>
# HACK: <临时方案>，待 <条件> 后移除
```

## Review 检查清单

- [ ] 魔法数字有来源说明
- [ ] 非显然逻辑有"为什么"注释
- [ ] 科研代码有单位/坐标系/论文引用
- [ ] 临时方案有 HACK/TODO 标记
