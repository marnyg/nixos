import Config

# Test configuration
config :logger, level: :warn

# Database configuration for test
config :agentic_dm, AgenticDm.Repo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10