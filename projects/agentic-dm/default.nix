# Agentic DM - AI-powered tabletop RPG assistant
{ ... }: {
  perSystem = { pkgs, lib, ... }: {
    # Development shell for Agentic DM
    devenv.shells.agentic-dm = {
      name = "agentic-dm";

      # Disable container processes (requires additional flake inputs)
      containers = lib.mkForce { };

      # Enable Elixir development environment
      languages.elixir.enable = true;

      # PostgreSQL for game data storage
      services.postgres = {
        enable = true;
        initialDatabases = [{ name = "dnd_sessions_dev"; }];
      };

      # Project-specific packages
      packages = with pkgs; [
        inotify-tools # For Phoenix live reload
      ];

      enterShell = ''
        echo "🎲 Agentic DM Development Environment"
        echo "AI-powered tabletop RPG assistant"
        echo ""
        echo "Commands:"
        echo "  mix deps.get      - Install dependencies"
        echo "  mix compile       - Compile the project"
        echo "  mix test          - Run tests"
        echo "  mix ecto.create   - Create database"
        echo "  mix ecto.migrate  - Run migrations"
        echo "  iex -S mix        - Start interactive shell"
        echo ""
      '';
    };

    # Future: package the application
    # packages.agentic-dm = pkgs.mixRelease { ... };
  };
}
