{ user, ... }:

{
  # ============================================================
  # 系统级（nix-darwin）配置
  # 负责用户、Homebrew 等系统层面的设置
  # ============================================================

  # Determinate Nix 已接管 Nix 守护进程，
  # 因此这里禁用 nix-darwin 自带的 Nix 守护进程，避免冲突
  nix.enable = false;

  # 允许安装非自由（unfree）许可证的软件
  nixpkgs.config.allowUnfree = true;
  # 目标平台：aarch64-darwin 表示 Apple Silicon（M1/M2/M3…）
  # 如果是 Intel CPU，请改成 x86_64-darwin
  nixpkgs.hostPlatform = "aarch64-darwin";

  # 默认登录用户
  system.primaryUser = "zhi";
  # 用户 zhi 的家目录
  users.users.zhi = {
    home = "/Users/zhi";
  };
  # nix-darwin 的状态版本号，升级时不要随意改动
  system.stateVersion = 6;

  # 启用 nix-homebrew：以 Nix 方式管理 Homebrew
  nix-homebrew = {
    enable = true;
    # 由用户 zhi 来安装/管理 brew 包
    user = "zhi";
  };

  # Homebrew 配置：声明需要安装的 GUI 应用（casks）
  homebrew = {
    enable = true;
    # 每次激活时 zap 掉未在配置中列出的 brew 包，保持环境干净
    onActivation.cleanup = "zap";
    # 每次激活时自动执行 brew update
    onActivation.autoUpdate = true;
    # 强制执行，绕过部分交互式确认
    onActivation.extraFlags = [ "--force" ];
    # 通过 Homebrew Formula 安装的命令行工具列表
    # 适合放命令行工具，保持和 casks 一样的声明式管理风格
    brews = [
      "fastfetch"  # 系统信息概览工具，启动时展示硬件/OS 等信息
    ];
    # 通过 Homebrew Cask 安装的 GUI 应用列表
    casks = [
      "kitty"  # 终端模拟器 kitty
    ];
  };
}
