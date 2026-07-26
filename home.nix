{ config, pkgs, user, ... }:

let
  # dotfiles 仓库在 $HOME 下的软链路径（由 rebuild.sh 创建）
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  # ============================================================
  # Home Manager 用户级配置
  # 管理命令行工具、shell、终端等用户层面的环境
  # ============================================================

  home.username = "zhi";
  home.homeDirectory = "/Users/zhi";
  # home-manager 状态版本，不要随意修改
  home.stateVersion = "24.11";

  # 通过 Nix 安装的命令行工具（会在 PATH 中可用）
  home.packages = with pkgs; [
    # 日常高频命令行工具
    ripgrep   # rg：极快的文本搜索（grep 替代品）
    fd        # fd：极快的文件查找（find 替代品）
    fzf       # 模糊查找器（文件、历史、命令等）
    jq        # 命令行 JSON 处理工具
    # 终端/编辑器中渲染图标用的字体
    nerd-fonts.jetbrains-mono
  ];

  # 启用 fontconfig，让系统识别 Nix 安装的字体
  fonts.fontconfig.enable = true;

  # ============================================================
  # Zsh 配置
  # ============================================================
  programs.zsh = {
    enable = true;
    # 根据历史自动补全建议（灰字提示）
    autosuggestion.enable = true;
    # 命令实时语法高亮：合法命令绿色，非法命令红色
    syntaxHighlighting.enable = true;
    # 常用 shell 别名
    shellAliases = {
      ".." = "cd ..";            # 快速回到上级目录
      add = "git add .";         # 暂存所有改动
      push = "git push";         # 推送到远程
      pull = "git pull";         # 拉取远程
    };
  };

  # ============================================================
  # Starship：跨 shell 的极简提示符
  # ============================================================
  programs.starship = {
    enable = true;
    settings = {
      # 不在提示符前自动加空行
      add_newline = false;
      # 提示符格式：目录 + git 分支 + git 状态 + 命令耗时 + 换行 + 符号
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      # 提示符最右侧的字符：成功紫色，失败红色
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      # 命令执行耗时显示格式
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # ============================================================
  # kitty 终端配置
  # 采用“原地编辑”方式：真实文件保留在本仓库里，
  # ~/.config/kitty 通过符号链接指向仓库内的配置，便于在 Git 中追踪修改
  # ============================================================
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/kitty";
}
