# VIBE

面向科研人员的 AI Agent 架构系统。

## 什么是 VIBE

VIBE 是一个为科研工作流设计的 AI Agent 架构，包含：

- **AGENTS.md**：顶层入口，定义核心原则和路由
- **Workflows**：预设的作业流程（科研idea、问题咨询、代码调试、工程构建）
- **Skills**：可复用的能力模块
- **Agents**：可委派的子 Agent 定义
- **MCPs**：底层工具接口

## 目录结构

```
vibe/
├── AGENTS.template.md    # AGENTS.md 模板
├── install.sh            # 项目适配脚本
├── agents/               # Subagent 定义
│   ├── Debug.agent.md
│   ├── Research.agent.md
│   └── Review.agent.md
├── skills/               # Skill 集合
│   ├── idea-plan/        # [submodule] 科研规划
│   ├── annotation/
│   ├── idea-clarify/
│   └── ...
└── workflows/            # Workflow 定义
    ├── idea-assistant.md
    ├── question-consult.md
    ├── code-debug.md
    └── engineering.md
```

## 使用方式

### 适配到新项目

```bash
git clone https://github.com/riemac/vibe.git ~/vibe
cd ~/vibe && git submodule update --init --recursive

# 适配到项目
~/vibe/install.sh /path/to/your/project
```

### 更新 vibe

```bash
cd ~/vibe
git pull
git submodule update --recursive
```

## 架构层级

```
顶层入口   →  AGENTS.md（路由索引）
编排层     →  Workflows（作业流程）
执行层     →  Skills + Subagents
基础层     →  MCPs（工具接口）
```

**依赖规则**：低层不依赖高层，单向依赖。

## License

MIT
