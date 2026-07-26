#!/usr/bin/env bash
# ============================================================
# rebuild.sh：重建并应用本仓库定义的 macOS Nix 配置
# 用法：在仓库根目录下执行 `./rebuild.sh`
# 流程：
#   1. 把本仓库链接到 ~/.dotfiles（home.nix 中会引用此路径）
#   2. 用 sudo 调用 darwin-rebuild，应用 flake#wzy-mac 配置
# ============================================================

# 严格模式：遇到错误立即退出、未定义变量报错、管道中任一命令失败即失败
set -euo pipefail

# 解析脚本所在目录的绝对路径（不跟随软链），即本仓库的根目录
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# 在用户家目录下创建 ~/.dotfiles 软链，指向本仓库
# -s：符号链接；-f：已存在则覆盖；-n：把软链当普通文件处理
ln -sfn "$DIR" ~/.dotfiles

# 用 sudo 执行 darwin-rebuild：
#   switch     — 切换到新配置（同时构建并应用）
#   --flake    — 使用 flake 格式的配置
#   ~/.dotfiles#wzy-mac — flake 路径 + 目标配置名
exec sudo darwin-rebuild switch --flake ~/.dotfiles#wzy-mac
