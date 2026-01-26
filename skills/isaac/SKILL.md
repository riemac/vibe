---
name: isaac
description: Isaac Lab project-specific conventions. Environment activation, standalone AppLauncher pattern.
---

# Isaac Lab Development Skill

## Environment Setup

**Environment Activation:**
Before executing any terminal commands, activate the uv environment in the `~/isaac` directory:

```bash
source ~/isaac/env_isaac/bin/activate
```

## Script & Documentation Development

### Script Development Pattern
* Follow the **standalone development mode**, using **AppLauncher** as the core launcher
* All scripts must be self-contained and properly initialize the Isaac Sim application context
