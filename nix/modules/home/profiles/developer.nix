# Developer profile - Common development tools and configurations
{ lib, pkgs, ... }:

{
  # Essential development tools
  modules.my = {
    git.enable = true;
    direnv.enable = true;
    tmux.enable = true;
    fzf.enable = true;
    nixvim.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    myPackages.enable = true;
    cloneDefaultRepos.enable = lib.mkDefault true;
  };

  # Development programs
  programs = {
    # Version control
    gh.enable = true;

    # Better CLI tools
    bat.enable = true;
    eza.enable = true;
    jq.enable = true;

    # System monitoring
    htop.enable = true;
  };

  # Development packages
  home.packages = with pkgs; [
    # CLI tools not available as programs
    ripgrep
    fd
    yq-go
    btop

    # Build tools
    gnumake
    cmake
    pkg-config

    # Language servers and formatters
    nil # Nix LSP
    nixpkgs-fmt
    nodePackages.prettier

    # Container tools
    docker-compose
    lazydocker

    # Network tools
    curl
    wget
    httpie

    # File tools
    tree
    ncdu
    duf

    # Process management
    killall
    pstree
    lsof

    # Archive tools
    unzip
    zip
    unrar
  ];

  # Shell aliases for development
  home.shellAliases = {
    # Git shortcuts
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline --graph";
    gd = "git diff";

    # Docker shortcuts
    d = "docker";
    dc = "docker-compose";

    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # Improved ls
    l = "eza -l";
    la = "eza -la";
    ll = "eza -l";
    lt = "eza --tree";

    # Safety nets
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";
  };
}
