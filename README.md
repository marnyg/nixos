# NixOS Configuration

A modular, flake-based NixOS configuration supporting multiple hosts (desktop, laptop, WSL) with Home Manager integration.

## 🚀 Quick Start

### Prerequisites
- NixOS with flakes enabled
- Git for cloning the repository

### Installation

1. Clone this repository:
```bash
git clone https://github.com/marnyg/nixos.git ~/nixos
cd ~/nixos
```

2. Build and switch to a configuration:
```bash
# For desktop
sudo nixos-rebuild switch --flake .#desktop

# For laptop
sudo nixos-rebuild switch --flake .#laptop

# For WSL
sudo nixos-rebuild switch --flake .#wsl
```

### Development Environment

Enter the development shell with all tools:
```bash
nix develop
# or with direnv installed
direnv allow
```

## 📁 Architecture

### Directory Structure

```
.
├── flake.nix           # Flake entrypoint
├── nix/
│   ├── flake-modules/  # Flake-parts modules
│   ├── hosts/          # Host-specific configurations
│   ├── modules/        # Shared NixOS and Home Manager modules
│   └── users/          # User configurations and metadata
├── pkgs/               # Custom packages
└── CRUSH.md           # Development commands and code style guide
```

### Module System

This configuration uses a layered module system:

1. **Host Layer** (`nix/hosts/`): Machine-specific configurations
2. **Profile Layer** (`nix/modules/*/profiles/`): Reusable configuration sets
3. **Module Layer** (`nix/modules/`): Individual feature modules
4. **User Layer** (`nix/users/`): User-specific configurations

### Key Concepts

- **Profiles**: Predefined sets of modules (e.g., `desktop`, `developer`, `minimal`)
- **Modules**: Individual features that can be enabled/disabled
- **Users**: Managed through the custom `my.users` system

## 🛠️ Common Tasks

### Adding a New Host

1. Create a new directory under `nix/hosts/`:
```bash
mkdir -p nix/hosts/myhost
```

2. Create `default.nix` with your configuration:
```nix
{ inputs, config, pkgs, ... }:
{
  imports = [
    ./hardware.nix  # Hardware-specific config
    ../../modules/nixos/profiles/desktop.nix  # Or laptop.nix, server.nix
  ];

  # Host-specific configuration
  networking.hostName = "myhost";
  system.stateVersion = "23.11";

  # Enable user
  my.users.mar = {
    enable = true;
    enableHome = true;
    profiles = [ "developer" "desktop" ];
  };
}
```

3. Add to `nix/flake-modules/nixos.nix`:
```nix
flake.nixosConfigurations = {
  # ... existing hosts ...
  myhost = nixosSystemFor "x86_64-linux" ../hosts/myhost;
};
```

### Adding a New User

1. Create user directory structure:
```bash
mkdir -p nix/users/newuser
```

2. Create user metadata (`nix/users/newuser/default.nix`):
```nix
{
  username = "newuser";
  fullName = "Full Name";
  email = "user@example.com";

  preferences = {
    shell = "fish";
    editor = "nixvim";
    terminal = "ghostty";
    browser = "firefox";
  };

  profiles = {
    wsl = [ "minimal" ];
    desktop = [ "developer" "desktop" ];
    laptop = [ "developer" "desktop" ];
  };
}
```

3. Create system configuration (`nix/users/newuser/system.nix`):
```nix
{ pkgs, ... }:
{
  isNormalUser = true;
  description = "Full Name";
  shell = pkgs.fish;
  extraGroups = [ "wheel" "networkmanager" "docker" ];
  openssh.authorizedKeys.keys = [ ];
}
```

4. Register in `nix/modules/nixos/core/users.nix`:
```nix
userRegistry = {
  users = {
    mar = ../../../users/mar;
    newuser = ../../../users/newuser;  # Add this line
  };
};
```

### Managing Profiles

Profiles are collections of modules that work well together:

- **`minimal`**: Basic shell environment with essential tools
- **`developer`**: Development tools, editors, and utilities
- **`desktop`**: GUI applications and desktop environment

To use profiles, specify them in your user configuration:
```nix
my.users.username = {
  enable = true;
  enableHome = true;
  profiles = [ "developer" "desktop" ];  # Combines both profiles
};
```

### Enabling/Disabling Modules

Modules can be controlled at the host level:
```nix
# In your host configuration
my.users.mar = {
  extraHomeModules = [{
    modules.firefox.enable = true;
    modules.nixvim.enable = true;
    modules.tmux.enable = false;
  }];
};
```

## 🔧 Development

### Available Commands

See `CRUSH.md` for the full development command reference.

Common commands:
```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#<host>

# Run tests
nix flake check

# Format code
nix fmt

# Update flake inputs
nix flake update

# Build VM for testing
nix build .#nixosConfigurations.miniVm.config.system.build.vm
./result/bin/run-nixos-test-vm
```

### WSL-Specific Instructions

For WSL environments, follow these steps:

1. Build the WSL installer:
```bash
nix build .#nixosConfigurations.wsl.config.system.build.installer
```

2. Import in Windows:
```powershell
wsl --import NixOS C:\path\to\storage .\result\tarball\nixos-wsl-installer.tar.gz --version 2
wsl -d NixOS
```

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## 📝 License

This configuration is provided as-is for reference and learning purposes.