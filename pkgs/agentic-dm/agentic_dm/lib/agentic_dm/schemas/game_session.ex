defmodule AgenticDm.Schemas.GameSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "game_sessions" do
    field :session_id, :string
    field :campaign_name, :string
    field :dm_name, :string
    field :status, :string, default: "active"
    
    # Session Data
    field :character_ids, {:array, :binary_id}, default: []
    field :world_state_id, :binary_id
    field :conversation_history, {:array, :map}, default: []
    field :session_summary, :string
    field :context_tokens_used, :integer, default: 0
    
    # Session Settings
    field :llm_model, :string, default: "anthropic/claude-3.5-sonnet"
    field :max_context_tokens, :integer, default: 200_000
    field :temperature, :float, default: 0.7
    field :auto_save_interval, :integer, default: 300
    
    # Metadata
    field :session_start, :utc_datetime
    field :session_end, :utc_datetime
    field :last_activity, :utc_datetime
    field :notes, :string
    
    timestamps()
  end

  @doc false
  def changeset(game_session, attrs) do
    game_session
    |> cast(attrs, [
      :session_id, :campaign_name, :dm_name, :status, :character_ids,
      :world_state_id, :conversation_history, :session_summary,
      :context_tokens_used, :llm_model, :max_context_tokens,
      :temperature, :auto_save_interval, :session_start, :session_end,
      :last_activity, :notes
    ])
    |> validate_required([:session_id, :campaign_name])
    |> validate_inclusion(:status, ["active", "paused", "completed", "archived"])
    |> validate_number(:temperature, greater_than: 0.0, less_than_or_equal_to: 2.0)
    |> validate_number(:max_context_tokens, greater_than: 1000)
    |> unique_constraint(:session_id)
  end
  
  def add_message(session, role, content, metadata \\ %{}) do
    message = %{
      role: role,
      content: content,
      timestamp: DateTime.utc_now(),
      metadata: metadata
    }
    
    new_history = [message | session.conversation_history]
    %{session | 
      conversation_history: new_history, 
      last_activity: DateTime.utc_now()
    }
  end
  
  def update_context_usage(session, tokens_used) do
    %{session | 
      context_tokens_used: session.context_tokens_used + tokens_used,
      last_activity: DateTime.utc_now()
    }
  end
  
  def pause_session(session) do
    %{session | 
      status: "paused", 
      last_activity: DateTime.utc_now()
    }
  end
  
  def complete_session(session) do
    %{session | 
      status: "completed", 
      session_end: DateTime.utc_now(),
      last_activity: DateTime.utc_now()
    }
  end
end