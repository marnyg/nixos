# CRUSH.md - Code Reference for Unified Shell Habits

This file contains quick reference commands and code style guidelines for developing
this NixOS configuration. Keep this file open in a split pane for easy reference.

## Development Commands
- Build system: `nixos-rebuild switch --flake .#<system>`
- Run tests: `nix flake check` 
- Run specific test: `nix build .#checks.x86_64-linux.<test-name>`
- Format code: `nix run .#formatter` or `treefmt`
- Lint: `deadnix`, `statix`, `nil` (via pre-commit hooks)
- Enter dev shell: `nix develop` or `devenv shell`

# Code Style Guidelines
- Nix: Use nixpkgs-fmt, 2-space indentation, snake_case names
- Imports: Absolute paths starting with ./, group related imports
- Types: Use lib.types with proper descriptions in options
- Error handling: Use mkIf for conditional config, wrap with lib.optional
- Comments: Only for complex logic, avoid obvious comments
- Module structure: options with descriptions, config with mkIf guards
- Home Manager: modules.* namespace, NixOS: myModules.* namespace