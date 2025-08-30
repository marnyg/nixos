import Config

# Configure the database
config :agentic_dm, AgenticDm.Repo,
  database: Path.expand("../dnd_sessions.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  show_sensitive_data_on_connection_error: true

config :agentic_dm, ecto_repos: [AgenticDm.Repo]

# Environment-specific configuration
import_config "#{config_env()}.exs"