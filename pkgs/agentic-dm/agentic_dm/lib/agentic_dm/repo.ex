defmodule AgenticDm.Repo do
  use Ecto.Repo,
    otp_app: :agentic_dm,
    adapter: Ecto.Adapters.SQLite3
end