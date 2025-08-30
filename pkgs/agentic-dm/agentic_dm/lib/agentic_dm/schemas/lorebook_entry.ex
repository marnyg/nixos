defmodule AgenticDm.Schemas.LorebookEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "lorebook_entries" do
    field :title, :string
    field :content, :string
    field :keywords, {:array, :string}, default: []
    field :priority, :integer, default: 1
    field :category, :string
    field :campaign_name, :string
    
    # Trigger Settings
    field :trigger_conditions, :map, default: %{}
    field :insertion_order, :integer, default: 100
    field :max_triggers_per_session, :integer, default: 5
    field :current_session_triggers, :integer, default: 0
    
    # Content Management
    field :token_budget, :integer, default: 500
    field :insertion_position, :string, default: "context"
    field :active, :boolean, default: true
    field :auto_trigger, :boolean, default: true
    
    # Metadata
    field :created_by, :string
    field :last_triggered, :utc_datetime
    field :trigger_count, :integer, default: 0
    field :notes, :string
    
    timestamps()
  end

  @doc false
  def changeset(lorebook_entry, attrs) do
    lorebook_entry
    |> cast(attrs, [
      :title, :content, :keywords, :priority, :category, :campaign_name,
      :trigger_conditions, :insertion_order, :max_triggers_per_session,
      :current_session_triggers, :token_budget, :insertion_position,
      :active, :auto_trigger, :created_by, :last_triggered, :trigger_count, :notes
    ])
    |> validate_required([:title, :content, :campaign_name])
    |> validate_number(:priority, greater_than: 0, less_than_or_equal_to: 10)
    |> validate_number(:token_budget, greater_than: 0, less_than_or_equal_to: 5000)
    |> validate_inclusion(:insertion_position, ["context", "system", "user", "assistant"])
  end
  
  def matches_keywords?(entry, text) do
    text_lower = String.downcase(text)
    
    Enum.any?(entry.keywords, fn keyword ->
      keyword_lower = String.downcase(keyword)
      String.contains?(text_lower, keyword_lower)
    end)
  end
  
  def can_trigger?(entry) do
    entry.active and 
    entry.auto_trigger and 
    entry.current_session_triggers < entry.max_triggers_per_session
  end
  
  def trigger_entry(entry) do
    %{entry | 
      current_session_triggers: entry.current_session_triggers + 1,
      trigger_count: entry.trigger_count + 1,
      last_triggered: DateTime.utc_now()
    }
  end
  
  def reset_session_triggers(entry) do
    %{entry | current_session_triggers: 0}
  end
  
  def calculate_relevance_score(entry, recent_messages) do
    combined_text = 
      recent_messages
      |> Enum.map(&Map.get(&1, :content, ""))
      |> Enum.join(" ")
      |> String.downcase()
    
    keyword_matches = 
      Enum.count(entry.keywords, fn keyword ->
        String.contains?(combined_text, String.downcase(keyword))
      end)
    
    base_score = entry.priority * 10
    keyword_score = keyword_matches * 5
    recency_penalty = entry.current_session_triggers * 2
    
    max(0, base_score + keyword_score - recency_penalty)
  end
end