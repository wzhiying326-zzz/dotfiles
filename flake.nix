{
  # ============================================================
  # wzy 的 macOS dotfiles 配置（Nix Flake 入口）
  # 通过 nix-darwin + home-manager 管理整个系统与用户环境
  # ============================================================
  description = "wzy's mac-dotfiles ";

  # ============================================================
  # nixConfig：全局生效的 Nix 配置（注入到 nix-darwin 和 home-manager）
  # 这里配置二进制缓存（substituter），让 Nix 优先从中国镜像下载预编译产物
  # ============================================================
  nixConfig = {
    # 二进制缓存镜像列表（按优先级排列，前面的优先）
    # - SJTUG（上交）：唯一镜像 nix-darwin binary cache 的镜像站，优先级最高
    # - TUNA / USTC / BFSU：三家均同步 nixpkgs binary cache，互为备份
    # - cache.nixos.org / nix-community.cachix.org：官方兜底
    extra-substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    # 各 substituter 对应的签名公钥
    # 高校镜像复用 cache.nixos.org 的公钥，cachix 用自己的公钥
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # ============================================================
    # inputs：声明本配置依赖的所有外部输入源
    # ============================================================

    # Nixpkgs：Nix 官方软件包仓库（固定到 darwin 专用分支 26.05）
    # 如需切换版本，改成 `github:NixOS/nixpkgs/nixpkgs-26.05-darwin`
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin" ;

    # nix-darwin：在 macOS 上以 Nix 方式管理系统配置
    # 同样固定到 26.05 分支，与 nixpkgs 保持一致
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    # 让 nix-darwin 复用上面声明的 nixpkgs，避免重复下载
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager：以声明式方式管理用户级配置（dotfiles、CLI 工具等）
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew：把 Homebrew 集成到 Nix 中，方便用 Nix 安装 brew 包
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
    {
      # ============================================================
      # outputs：定义本 flake 的输出
      # 这里导出一份名为 "wzy-mac" 的 darwin 系统配置
      # 执行 `darwin-rebuild switch --flake .#wzy-mac` 即可应用
      # ============================================================
      darwinConfigurations."wzy-mac" = nix-darwin.lib.darwinSystem {
        modules = [
          # 系统级配置（用户、Homebrew 等）
          ./configuration.nix
          # 引入 nix-homebrew 模块以管理 Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          # 引入 home-manager 模块以管理用户环境
          home-manager.darwinModules.home-manager
          {
            # 使用全局 pkgs，避免 home-manager 重复下载
            home-manager.useGlobalPkgs = true;
            # 允许 home-manager 管理用户的可执行包（PATH）
            home-manager.useUserPackages = true;
            # 为用户 wzy 加载 ./home.nix 中的用户级配置
            home-manager.users.wzy = import ./home.nix;
            # 覆盖同名文件时备份为 .bak，防止误覆盖
            home-manager.backupFileExtension = ".bak";
          }
        ];
      };
    };
}
