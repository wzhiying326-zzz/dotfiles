# wzy 的 macOS dotfiles

通过 [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) + [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) 声明式管理 macOS 系统配置与用户环境。

> 目标机器：Apple Silicon (`aarch64-darwin`) macOS。用户：`zhi`。

---

## 在新机器上从零部署

### 1. 安装 Chrome

从[官网](https://www.google.com/chrome/)下载 Chrome 并安装。后续步骤中需要 Chrome 登录 GitHub。

### 2. 激活 macOS 命令行工具链（含 git）

打开终端，执行：

```bash
xcode-select --install
```

按提示安装 **Command Line Tools for Xcode**——这一步会同时提供 `git`，是后续所有操作的前提。

### 3. 配置 git

```bash
git config --global user.name  "你的 GitHub 用户名"
git config --global user.email "你的 GitHub 邮箱"
```

### 4. 为 GitHub 配置 SSH

1. 生成密钥（邮箱替换为上一步设置的邮箱）：

   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

   一路回车使用默认路径与空密码即可。

2. 启动 ssh-agent 并添加密钥：

   ```bash
   eval "$(ssh-agent -s)"
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```

3. 把公钥添加到 GitHub：

   ```bash
   pbcopy < ~/.ssh/id_ed25519.pub
   ```

   然后打开 Chrome，登录 GitHub → **Settings → SSH and GPG keys → New SSH key**，粘贴并保存。

4. 验证连接：

   ```bash
   ssh -T git@github.com
   ```

   看到 `Hi <username>! You've successfully authenticated...` 即成功。

### 5. 安装 Determinate Nix

本配置依赖 [Determinate Nix](https://docs.determinate.systems/)（`configuration.nix` 中 `nix.enable = false`，由 Determinate 接管守护进程）。

> ⚠️ **目前 Determinate Nix 仅提供官方安装包**，暂未提供命令行安装方式。请前往[官网下载页面](https://docs.determinate.systems/getting-started)获取最新的 `.pkg` 安装包，双击按向导完成安装。

安装完成后**退出当前终端并重新打开**，让 PATH 生效。可用以下命令验证：

```bash
nix --version
```

### 6. 克隆本仓库

仓库路径没有硬编码，但建议放在固定位置以便记忆：

```bash
mkdir -p ~/github/wzy
git clone <本仓库地址> ~/github/wzy/dotfiles
cd ~/github/wzy/dotfiles
```

### 7. 执行重建脚本

```bash
./rebuild.sh
```

脚本会自动：

- 把仓库软链到 `~/.dotfiles`（`home.nix` 中引用此路径）
- 以 `sudo` 调用 `darwin-rebuild switch --flake ~/.dotfiles#wzy-mac`，构建并应用整套配置

首次构建需要较长时间（需下载大量 Nix 包、Homebrew Formula/Cask），属正常现象。

---

## 日常使用

### 修改配置后应用

```bash
cd ~/github/wzy/dotfiles
./rebuild.sh
```

或直接：

```bash
sudo darwin-rebuild switch --flake ~/.dotfiles#wzy-mac
```

### 更新 flake 输入

```bash
nix flake update             # 更新所有 inputs
sudo darwin-rebuild switch   # 应用
```

### 回滚到上一个配置

```bash
sudo darwin-rebuild rollback
```

---

## 目录结构

```
.
├── flake.nix          # flake 入口 + 二进制缓存镜像 + outputs
├── configuration.nix  # nix-darwin 系统级配置（用户、Homebrew 等）
├── home.nix           # home-manager 用户级配置（CLI 工具、shell、终端）
├── rebuild.sh         # 一键重建脚本
└── home/
    └── .config/
        └── kitty/     # kitty 配置（通过 symlink 接入）
```

### 各文件职责

| 文件 | 管理什么 |
|------|---------|
| `configuration.nix` | macOS 用户、Homebrew（命令行工具 + GUI 应用） |
| `home.nix` | 命令行工具、zsh、yazi、starship、kitty 配置软链 |
| `flake.nix` | 锁定的 nixpkgs-26.05 / nix-darwin-26.05 / home-manager-26.05 通道 |

---

## 配置说明

### 二进制缓存

`flake.nix` 中配置了中国高校镜像（优先级从上到下）：

- SJTUG（上交）
- TUNA（清华）
- USTC（中科大）
- BFSU（北京外国语）

均复用 `cache.nixos.org` 的签名公钥，官方 `cache.nixos.org` 与 `nix-community.cachix.org` 作为兜底。

### kitty 配置

`kitty/` 目录被 `home.nix` 以符号链接方式挂到 `~/.config/kitty`，可直接在仓库内编辑后提交。

GUI 安装走 Homebrew Cask（`configuration.nix` 中），配置走 home-manager，二者职责分离。

### Homebrew

`onActivation.cleanup = "zap"` 会在每次激活时移除未列出的 brew 包——相当于"环境收敛"。添加新包：

- 命令行工具 → `configuration.nix` 的 `homebrew.brews`
- GUI 应用 → `configuration.nix` 的 `homebrew.casks`

---

## 注意事项

- **`home.stateVersion` 已固定为 `24.11`**，与 home-manager 的迁移逻辑绑定，**不要随意改动**。改它会触发迁移评估，并非语法错误但会产生意外行为。
- `configuration.nix` 的 `system.stateVersion = 6` 同样是 nix-darwin 的迁移版本号，不要改动。
- `nixpkgs.hostPlatform = "aarch64-darwin"` 假设 Apple Silicon。若使用 Intel Mac，需改为 `x86_64-darwin`。
- 不要把 `nix.enable` 改回 `true`，否则会与 Determinate Nix 的守护进程冲突。

---

## 故障排查

| 现象 | 排查方向 |
|------|---------|
| `darwin-rebuild: command not found` | Nix 未安装或当前终端 PATH 没刷新，重新打开终端 |
| 构建卡在下载阶段 | 检查 `flake.nix` 中镜像是否可达；临时切回官方 `cache.nixos.org` |
| kitty 启动后乱码/方块 | JetBrainsMono Nerd Font 未生效，等待 home-manager 激活完成或重启 kitty |
| brew 包未生效 | `brew --prefix` 检查 PATH；查看 `~/.config/brew-update.log` |
| home-manager 冲突 | `~/.dotfiles` 软链是否指向了正确目录 |