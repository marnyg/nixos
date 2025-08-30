import Config

# Production configuration
config :logger, level: :info

# Database configuration for production
config :agentic_dm, AgenticDm.Repo,
  database: System.get_env("DATABASE_PATH") || "dnd_sessions.db",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")