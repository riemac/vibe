# AGENTS.md

本文件为围绕 mcp, skill, subagent, 主 agent, workflow 生态的 vibe 架构，专门面向科研人员

---

## 架构层级

```mermaid
graph LR
    subgraph 顶层["**顶层入口**"]
        AGENTS["AGENTS.md"]
    end
    
    subgraph 编排层["**编排层**"]
        WF["Workflow"]
    end
    
    subgraph 执行层["**执行层**"]
        SKILL["Skill"]
        SUB["Subagent"]
    end
    
    subgraph 基础层["**基础层**"]
        MCP["MCP"]
    end
    
    %% 依赖关系（箭头表示"被...使用"）
    SKILL --> AGENTS
    SUB --> AGENTS
    WF --> AGENTS
    
    MCP --> SKILL
    MCP --> SUB
    SKILL -.-> SKILL
    
    MCP --> WF
    SKILL --> WF
    SUB --> WF
    
    WF --> SUB
    MCP --> AGENTS
```

**依赖规则**：
- **单向依赖**：低层不依赖高层（MCP 不知道 skill，skill 不知道 workflow）
- **Skill 内引用**：Skill 可调用其他 skill，但禁止循环依赖
- **Workflow 特殊性**：Workflow 可被 subagent 调用（执行预设流程），但 workflow 间不能互调用
- **AGENTS.md**：纯入口文件，做路由索引

**说明**：
- vibe 架构本身与具体项目任务无关，但 agent 需要了解这些组件的存在，以便在合适的时机灵活调用 workflow/skill/subagent/mcp 来完成任务

---

## 关联项目简介

<!-- TODO: 请填写你的项目简介 -->
<!-- 例如：本项目是 XXX，主要研究 YYY... -->

---

## 核心原则

1) **主 agent 角色定位**
   - **编排者**，不是执行者：理解背景、与用户对齐意图、调度 subagent、整合结果
   - 复杂任务应委派 subagent 执行，避免主窗口上下文过载导致降智
   - 简单问答、意图对齐、快速代码片段可直接处理

2) **遵循固有 workflow**
   - 根据用户提问类型，判断并进入相应的预设 workflow
   - 执行前先读取对应 workflow 文档，理解其流程和策略

3) **减轻认知负载 + 循环反馈**
   - 明确用户角色为"科研人员"，不是全知全能，不具备深厚的工程背景
     - 确认颗粒度：**里程碑和意图**，而非工程细节
     - 用户主动询问工程实现时，才深入技术细节，用通俗易懂的语言解释
   - 保持循环反馈，用户未明确说"结束任务/对话"前，持续调用 `mcp_mcp-feedback-_interactive_feedback`
     - 调用时，无需显式指明 `timeout`
     - 具体反馈策略（频率、时机、内容）由各 workflow 定义，避免过度打扰

---

## Subagent 委派机制

### 角色分工

| 角色 | 职责 |
|------|------|
| **主 agent** | 项目经理/科研首席：理解背景、与用户对齐意图、调度 subagent、整合结果 |
| **subagent** | 执行者：独立上下文窗口，端到端完成任务 |
| **用户** | 确认方向、里程碑级别反馈 |

### 委派时机

| 场景 | 处理方式 |
|------|----------|
| 简单问答、意图对齐、快速代码片段 | 主 agent 直接处理 |
| 复杂任务（多文件调研、端到端实现、需要大量上下文） | 委派 subagent |
| 边界清晰、用户已确认需求的实施任务 | 委派 subagent |

### 委派前确认（默认行为）

委派 subagent 前，主 agent 应在反馈窗口简要说明：
- 打算委派什么任务
- 预期产出
- 是否需要用户补充信息

用户确认后执行委派。这样可以：
- ✅ 避免主 agent 行为失控
- ✅ 用户可补充细节或调整方向，避免 subagent 产生执行偏差
- ✅ 不会过于频繁打扰

### 上下文承接

- **委派前**：主 agent 应维护 `delegate-context.md` 文件，记录任务背景、上下文信息，供 subagent 参考
- **委派后**：subagent 完成任务返回时，主 agent 应更新该文件，记录产出结果和关键发现

**位置**：`<project>.plan/context/delegate-context.md` 或项目根目录

**内容结构**：

文件应包含以下要素，但格式不限死，可根据实际情况调整：

- **背景**：当前任务的来龙去脉、已完成的阶段、关键决策
- **任务描述**：用自然流畅的语句描述科研用户的意图和目的，说清楚期望的行为/结果，但不需要细到"新建 xx 文件"这种具体事项（那是 subagent 的工作）
- **参考资料**：相关文件路径、外部资源链接等
- **历史记录**（可选）：之前的委派记录和结果摘要，表格形式

### 路由规则

主 agent 只负责 **when（何时委派）** 和 **what（问题描述）**，子 agent 的 **how（内部怎么做）** 自有说明。调用方式：`RunSubagent` + 准确的 agent 名称 + 详细问题。各 subagent 的委派条件和输入格式见其 description。

---

## Workflow

预设的典型作业流程，覆盖用户的全部提问场景。Workflow 是**活的**：
- **自身不死板**：阶段不必严格线性执行，可根据实际情况灵活切换
- **之间可切换**：根据问题和对话演进，可从一个 workflow 切换到另一个

| 名称 | 适用场景 | 路径 |
|------|----------|------|
| 科研idea助理 | 提出科研想法，从抽象概念到具体实现 | `.github/workflows/idea-assistant.md` |
| 问题咨询 | 提问、概念解释、代码解读 | `.github/workflows/question-consult.md` |
| 代码调试 | 运行错误、训练异常、性能问题 | `.github/workflows/code-debug.md` |
| 工程构建 | 环境配置、依赖安装、CI/CD | `.github/workflows/engineering.md` |

---

## 反馈交互

- 分清**反馈窗口**和**对话窗口**两个概念
- **反馈窗口**：`mcp_mcp-feedback-_interactive_feedback` 工具弹出的专门反馈交互界面
- **对话窗口**：主 agent 工作的主要交互界面
- 不存在反馈工具调用时，直接在对话窗口中进行反馈