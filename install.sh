#!/bin/bash
# install.sh - VIBE 架构适配脚本
# 将 vibe 仓库内容适配到目标项目

set -e

PROJECT_ROOT=${1:-.}
VIBE_ROOT=$(dirname "$(realpath "$0")")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=========================================="
echo "VIBE 适配脚本"
echo "=========================================="
echo "VIBE 源: $VIBE_ROOT"
echo "目标项目: $PROJECT_ROOT"
echo ""

# 备份函数：如果目标存在，则重命名为 .bak
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ]; then
        local backup="${target}.bak.${TIMESTAMP}"
        echo "  ⚠️  检测到已存在: $(basename "$target")"
        echo "      备份为: $(basename "$backup")"
        mv "$target" "$backup"
    fi
}

# 复制目录函数
copy_dir() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$src")
    
    if [ -d "$src" ]; then
        backup_if_exists "$dest"
        echo "  📁 复制 $name/"
        cp -r "$src" "$dest"
    fi
}

# 复制文件函数
copy_file() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$src")
    
    if [ -f "$src" ]; then
        backup_if_exists "$dest"
        echo "  📄 复制 $name"
        cp "$src" "$dest"
    fi
}

echo "1. 创建目录结构..."
mkdir -p "$PROJECT_ROOT/.github"

echo ""
echo "2. 适配 .github 内容..."
echo "   目标: $PROJECT_ROOT/.github/"

# 适配 agents, skills, workflows
for dir in agents skills workflows; do
    if [ -d "$VIBE_ROOT/$dir" ]; then
        copy_dir "$VIBE_ROOT/$dir" "$PROJECT_ROOT/.github/$dir"
    fi
done

echo ""
echo "3. 适配 AGENTS.md..."

# AGENTS.md 使用模板
if [ -f "$VIBE_ROOT/AGENTS.template.md" ]; then
    copy_file "$VIBE_ROOT/AGENTS.template.md" "$PROJECT_ROOT/AGENTS.md"
    echo "  💡 请编辑 AGENTS.md 填写项目特定信息（如关联项目简介）"
fi

echo ""
echo "=========================================="
echo "✅ 适配完成！"
echo ""
echo "备份文件（如有）可在以下位置找到："
echo "  - $PROJECT_ROOT/.github/*.bak.$TIMESTAMP"
echo "  - $PROJECT_ROOT/*.bak.$TIMESTAMP"
echo ""
echo "下一步："
echo "  1. 编辑 $PROJECT_ROOT/AGENTS.md 填写项目信息"
echo "  2. 根据需要调整 .github/ 下的内容"
echo "=========================================="
