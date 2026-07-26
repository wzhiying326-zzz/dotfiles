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
    # ===== 日常高频 CLI 工具 =====
    ripgrep              # rg：极快的文本搜索（grep 替代品）
    fd                   # fd：极快的文件查找（find 替代品）
    fzf                  # 模糊查找器（文件、历史、命令等）
    jq                   # 命令行 JSON 处理工具
    zoxide               # 智能 cd：记住常去的目录，`z foo` 跳转
    # ===== 终端/编辑器中渲染图标用的字体 =====
    nerd-fonts.jetbrains-mono
    # ===== yazi 终端文件管理器 =====
    yazi                 # 本体
    # ===== yazi 预览/搜索的外部依赖（缺一不可） =====
    # 注：yazi 自身不装这些，只通过 PATH 调子进程
    ffmpeg               # 视频缩略图
    chafa                # 终端里预览图片
    p7zip                # 7z / rar 压缩包预览（Nix 包名是 p7zip，不是 7zip）
    poppler-utils        # PDF 预览（pdftoppm）
    resvg                # SVG 矢量图预览
    imagemagick          # 通用图片处理兜底
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
    # 集成 zoxide：自动接管 z 命令（智能 cd）
    zoxideIntegration = true;
    # 常用 shell 别名
    shellAliases = {
      ".." = "cd ..";            # 快速回到上级目录
      add = "git add .";         # 暂存所有改动
      push = "git push";         # 推送到远程
      pull = "git pull";         # 拉取远程
    };
  };

  # ============================================================
  # Yazi：终端文件管理器
  # 仅启用本体 + zsh 集成，不引入插件/主题/自定义 keymap
  # 预览依赖见上方 home.packages 段
  # ============================================================
  programs.yazi = {
    enable = true;
    # 在 zsh 里集成：自动接管 y 命令
    enableZshIntegration = true;
    # 终端输入 y 即可启动 yazi（比 yazi 短）
    shellWrapperName = "y";

    settings = {
      # 文件管理器视图
      mgr = {
        # 默认显示隐藏文件（以 . 开头的文件）
        show_hidden = true;
      };
      # 预览面板
      preview = {
        # 预览图最大宽度（单位：列）
        max_width = 1000;
        # 预览图最大高度（单位：行）
        max_height = 1000;
      };
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
