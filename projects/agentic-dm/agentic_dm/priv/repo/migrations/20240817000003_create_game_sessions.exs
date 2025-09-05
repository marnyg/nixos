defmodule AgenticDm.Repo.Migrations.CreateGameSessions do
  use Ecto.Migration

  def change do
    create table(:game_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :session_id, :string, null: false
      add :campaign_name, :string, null: false
      add :dm_name, :string
      add :status, :string, default: "active"
      
      # Session Data
      add :character_ids, :text
      add :world_state_id, :binary_id
      add :conversation_history, :text
      add :session_summary, :text
      add :context_tokens_used, :integer, default: 0
      
      # Session Settings
      add :llm_model, :string, default: "anthropic/claude-3.5-sonnet"
      add :max_context_tokens, :integer, default: 200_000
      add :temperature, :real, default: 0.7
      add :auto_save_interval, :integer, default: 300
      
      # Metadata
      add :session_start, :utc_datetime
      add :session_end, :utc_datetime
      add :last_activity, :utc_datetime
      add :notes, :text

      timestamps()
    end

    create unique_index(:game_sessions, [:session_id])
    create index(:game_sessions, [:campaign_name])
    create index(:game_sessions, [:status])
    create index(:game_sessions, [:world_state_id])
  end
end