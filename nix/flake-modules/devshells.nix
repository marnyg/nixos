# Development shells flake module
{ ... }:

{
  perSystem = { pkgs, ... }: {
    # Development shells
    devShells = {
      # Default shell for NixOS development
      default = pkgs.mkShell {
        packages = with pkgs; [
          # Nix tools
          nixpkgs-fmt
          nil
          nix-tree
          nix-diff

          # System tools
          git
          vim

          # Flake tools
          fh # Flake helper
        ];

        shellHook = ''
          echo "╔══════════════════════════════════════════════════════════════╗"
          echo "║                 🚀 NixOS Development Environment              ║"
          echo "╚══════════════════════════════════════════════════════════════╝"
          echo ""
          echo "📦 Available Configurations:"
          echo "  • NixOS:  desktop, laptop, wsl"
          echo "  • Darwin: mac, mac-minimal"
          echo ""
          echo "🔧 Quick Commands:"
          echo "  ${"\033[1;32m"}# NixOS${"\033[0m"}"
          echo "  nixos-rebuild switch --flake .#<host>"
          echo ""
          echo "  ${"\033[1;34m"}# macOS${"\033[0m"}"
          echo "  darwin-rebuild switch --flake .#mac"
          echo "  nix run .#darwin-rebuild -- switch --flake .#mac"
          echo ""
          echo "  ${"\033[1;33m"}# Build without switching${"\033[0m"}"
          echo "  nix build .#nixosConfigurations.<host>.config.system.build.toplevel"
          echo "  nix build .#darwinConfigurations.mac.system"
          echo ""
          echo "⚡ Performance Optimizations Active:"
          echo "  ✓ Automatic fallback enabled (no --fallback needed)"
          echo "  ✓ Using all CPU cores ($(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo "?") cores available)"
          echo "  ✓ direnv caching enabled (near-instant shell reload)"
          echo "  ✓ Extended cache TTLs (4hr positive, 1hr negative)"
          echo ""
          echo "📊 Diagnostics:"
          echo "  ./nix-performance-diagnostic.sh  # Full system analysis"
          echo "  ./nix-flake-performance-test.sh  # Flake performance test"
          echo "  nix flake check                   # Validate configuration"
          echo ""
          echo "💡 Tips:"
          echo "  • Use 'direnv reload' if environment seems stale"
          echo "  • Run 'nix-collect-garbage -d' weekly for cleanup"
          echo "  • Check NIX-PERFORMANCE-REPORT.md for optimization details"
          echo ""
        '';

        EDITOR = "vim";
      };

      # Shell for working on packages
      packages = pkgs.mkShell {
        packages = with pkgs; [
          # Package development tools
          nix-build-uncached
          nix-update
          nixpkgs-review
        ];
      };
    };
  };
}
