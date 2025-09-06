# Developer profile - Common development tools and configurations
{ lib, pkgs, ... }:

{
  # Development modules
  modules.my = {
    # CORE: Essential for any developer
    git.enable = true; # Version control is mandatory
    direnv.enable = true; # Project environment management
    tmux.enable = true; # Terminal multiplexing for productivity
    fzf.enable = true; # Fuzzy finding is essential for navigation
    myPackages.enable = true; # Core development packages

    # OPTIONAL: Sensible defaults but can be overridden
    nixvim.enable = lib.mkDefault true; # Default editor, but vim/emacs users may override
    fish.enable = lib.mkDefault true; # Default shell, but zsh/bash users may override
    ghostty.enable = lib.mkDefault true; # Default terminal, but can be changed
    cloneDefaultRepos.enable = lib.mkDefault true; # Helpful but not mandatory
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
    ffmpeg
    jq
    tldr

    # Version control
    lazygit

    # Build tools
    gnumake
    cmake
    pkg-config

    # Language servers and formatters
    nil # Nix LSP
    nixpkgs-fmt
    nodePackages.prettier
    nodejs_24
    uv # Python package manager

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

    # Security
    gnupg
    bitwarden-cli

    # Development environments
    devenv
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
