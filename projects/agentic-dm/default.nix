# Agentic DM - AI-powered tabletop RPG assistant
{ ... }: {
  perSystem = { pkgs, ... }: {
    # Development shell for Agentic DM
    devShells.agentic-dm = pkgs.mkShell {
      name = "agentic-dm";

      # Project-specific packages
      packages = with pkgs; [
        # Elixir development
        elixir
        erlang

        # Database
        postgresql

        # Phoenix tools
        inotify-tools # For Phoenix live reload
      ];

      shellHook = ''
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
        echo "Note: PostgreSQL service needs to be started separately"
        echo "  pg_ctl -D $PGDATA init    - Initialize database"
        echo "  pg_ctl -D $PGDATA start   - Start PostgreSQL"
        echo ""
      '';

      # Environment variables for PostgreSQL
      PGDATA = "./postgres_data";
      DATABASE_URL = "postgresql://localhost/dnd_sessions_dev";
    };

    # Future: package the application
    # packages.agentic-dm = pkgs.mixRelease { ... };
  };
}
