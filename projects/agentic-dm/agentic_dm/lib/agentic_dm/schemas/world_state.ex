defmodule AgenticDm.Schemas.WorldState do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "world_states" do
    field :name, :string
    field :description, :string
    field :campaign_name, :string
    
    # World Environment
    field :current_location, :string
    field :time_of_day, :string, default: "midday"
    field :weather, :string, default: "clear"
    field :season, :string, default: "spring"
    field :date, :string
    
    # World Data
    field :locations, {:array, :map}, default: []
    field :npcs, {:array, :map}, default: []
    field :events, {:array, :map}, default: []
    field :story_flags, :map, default: %{}
    field :quest_log, {:array, :map}, default: []
    
    # State Management
    field :active, :boolean, default: true
    field :version, :integer, default: 1
    
    timestamps()
  end

  @doc false
  def changeset(world_state, attrs) do
    world_state
    |> cast(attrs, [
      :name, :description, :campaign_name, :current_location, 
      :time_of_day, :weather, :season, :date, :locations, 
      :npcs, :events, :story_flags, :quest_log, :active, :version
    ])
    |> validate_required([:name, :campaign_name])
    |> validate_inclusion(:time_of_day, ["dawn", "morning", "midday", "afternoon", "evening", "night", "midnight"])
    |> validate_inclusion(:season, ["spring", "summer", "autumn", "winter"])
  end
  
  def add_location(world_state, location) do
    new_locations = [location | world_state.locations]
    %{world_state | locations: new_locations, version: world_state.version + 1}
  end
  
  def add_npc(world_state, npc) do
    new_npcs = [npc | world_state.npcs]
    %{world_state | npcs: new_npcs, version: world_state.version + 1}
  end
  
  def add_event(world_state, event) do
    new_events = [event | world_state.events]
    %{world_state | events: new_events, version: world_state.version + 1}
  end
  
  def set_story_flag(world_state, flag, value) do
    new_flags = Map.put(world_state.story_flags, flag, value)
    %{world_state | story_flags: new_flags, version: world_state.version + 1}
  end
  
  def add_quest(world_state, quest) do
    new_quests = [quest | world_state.quest_log]
    %{world_state | quest_log: new_quests, version: world_state.version + 1}
  end
end