import Config

# Development configuration
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :info

# Database configuration for development
config :agentic_dm, AgenticDm.Repo,
  database: "dnd_sessions_dev.db",
  pool_size: 5