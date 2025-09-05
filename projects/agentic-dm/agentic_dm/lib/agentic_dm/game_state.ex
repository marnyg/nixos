defmodule AgenticDm.GameState do
  @moduledoc """
  Game state management with swappable storage backends.
  Provides a unified interface for managing characters, world states, and sessions.
  """
  
  alias AgenticDm.Repo
  alias AgenticDm.Schemas.{Character, WorldState, GameSession, LorebookEntry}
  
  # Character Management
  
  def create_character(attrs) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end
  
  def get_character(id) do
    case Repo.get(Character, id) do
      nil -> {:error, :not_found}
      character -> {:ok, character}
    end
  end
  
  def get_character_by_name(name) do
    case Repo.get_by(Character, name: name) do
      nil -> {:error, :not_found}
      character -> {:ok, character}
    end
  end
  
  def update_character(%Character{} = character) do
    character
    |> Character.changeset(%{})
    |> Repo.update()
  end
  
  def update_character(character_attrs) when is_map(character_attrs) do
    case get_character(character_attrs[:id] || character_attrs["id"]) do
      {:ok, character} ->
        character
        |> Character.changeset(character_attrs)
        |> Repo.update()
      error -> error
    end
  end
  
  def list_active_characters do
    import Ecto.Query
    Character
    |> where(active: true)
    |> Repo.all()
  end
  
  def get_session_characters(character_ids) when is_list(character_ids) do
    import Ecto.Query
    characters = Character
      |> where([c], c.id in ^character_ids)
      |> Repo.all()
    {:ok, characters}
  end
  
  def delete_character(id) do
    case get_character(id) do
      {:ok, character} -> Repo.delete(character)
      error -> error
    end
  end
  
  # World State Management
  
  def create_world_state(attrs) do
    %WorldState{}
    |> WorldState.changeset(attrs)
    |> Repo.insert()
  end
  
  def create_world_state_for_campaign(campaign_name) when is_binary(campaign_name) do
    attrs = %{
      name: "#{campaign_name} World",
      campaign_name: campaign_name,
      description: "World state for #{campaign_name}"
    }
    create_world_state(attrs)
  end
  
  def get_world_state(id) do
    case Repo.get(WorldState, id) do
      nil -> {:error, :not_found}
      world_state -> {:ok, world_state}
    end
  end
  
  def get_world_state_by_campaign(campaign_name) do
    case Repo.get_by(WorldState, campaign_name: campaign_name, active: true) do
      nil -> {:error, :not_found}
      world_state -> {:ok, world_state}
    end
  end
  
  def update_world_state(%WorldState{} = world_state) do
    world_state
    |> WorldState.changeset(%{})
    |> Repo.update()
  end
  
  def list_world_states do
    import Ecto.Query
    WorldState
    |> where(active: true)
    |> Repo.all()
  end
  
  # Game Session Management
  
  def create_session(session_id, campaign_name, world_state_id, opts \\ []) do
    attrs = %{
      session_id: session_id,
      campaign_name: campaign_name,
      world_state_id: world_state_id,
      session_start: DateTime.utc_now(),
      last_activity: DateTime.utc_now()
    }
    |> Map.merge(Map.new(opts))
    
    %GameSession{}
    |> GameSession.changeset(attrs)
    |> Repo.insert()
  end
  
  def get_session(session_id) do
    case Repo.get_by(GameSession, session_id: session_id) do
      nil -> {:error, :not_found}
      session -> {:ok, session}
    end
  end
  
  def update_session(%GameSession{} = session) do
    session
    |> GameSession.changeset(%{})
    |> Repo.update()
  end
  
  def list_active_sessions do
    import Ecto.Query
    GameSession
    |> where(status: "active")
    |> Repo.all()
  end
  
  def list_sessions_by_campaign(campaign_name) do
    import Ecto.Query
    GameSession
    |> where([s], s.campaign_name == ^campaign_name)
    |> order_by(desc: :last_activity)
    |> Repo.all()
  end
  
  # Lorebook Management
  
  def create_lorebook_entry(attrs) do
    %LorebookEntry{}
    |> LorebookEntry.changeset(attrs)
    |> Repo.insert()
  end
  
  def get_lorebook_entry(id) do
    case Repo.get(LorebookEntry, id) do
      nil -> {:error, :not_found}
      entry -> {:ok, entry}
    end
  end
  
  def update_lorebook_entry(%LorebookEntry{} = entry) do
    entry
    |> LorebookEntry.changeset(%{})
    |> Repo.update()
  end
  
  def list_lorebook_entries(campaign_name) do
    import Ecto.Query
    LorebookEntry
    |> where([l], l.campaign_name == ^campaign_name and l.active == true)
    |> order_by([l], [desc: l.priority, asc: l.insertion_order])
    |> Repo.all()
  end
  
  def find_relevant_lorebook_entries(campaign_name, keywords, limit \\ 10) do
    # This is a simple implementation. In a real system, you might want
    # to use full-text search or more sophisticated matching
    import Ecto.Query
    LorebookEntry
    |> where([l], l.campaign_name == ^campaign_name and l.active == true)
    |> Repo.all()
    |> Enum.filter(fn entry ->
      Enum.any?(entry.keywords, fn keyword ->
        Enum.any?(keywords, fn search_keyword ->
          String.contains?(
            String.downcase(keyword), 
            String.downcase(search_keyword)
          )
        end)
      end)
    end)
    |> Enum.sort_by(&(&1.priority), :desc)
    |> Enum.take(limit)
  end
  
  # Data Import/Export
  
  def import_sillytavern_character(character_json) do
    case Jason.decode(character_json) do
      {:ok, char_data} ->
        attrs = convert_sillytavern_character(char_data)
        create_character(attrs)
      error -> error
    end
  end
  
  def import_sillytavern_lorebook(lorebook_json, campaign_name) do
    case Jason.decode(lorebook_json) do
      {:ok, lorebook_data} ->
        entries = convert_sillytavern_lorebook(lorebook_data, campaign_name)
        
        # Insert all entries
        results = Enum.map(entries, &create_lorebook_entry/1)
        
        # Check if all succeeded
        case Enum.find(results, fn {status, _} -> status == :error end) do
          nil -> {:ok, length(entries)}
          error -> error
        end
      error -> error
    end
  end
  
  def export_character(character_id, format \\ :json) do
    case get_character(character_id) do
      {:ok, character} ->
        case format do
          :json -> {:ok, Jason.encode!(character)}
          :sillytavern -> {:ok, convert_to_sillytavern_character(character)}
          _ -> {:error, :unsupported_format}
        end
      error -> error
    end
  end
  
  # Statistics and Analytics
  
  def get_campaign_stats(campaign_name) do
    sessions = list_sessions_by_campaign(campaign_name)
    characters = Character |> Repo.all() # Could filter by campaign if we tracked that
    lorebook_entries = list_lorebook_entries(campaign_name)
    
    %{
      campaign_name: campaign_name,
      total_sessions: length(sessions),
      active_sessions: Enum.count(sessions, &(&1.status == "active")),
      total_characters: length(characters),
      active_characters: Enum.count(characters, &(&1.active)),
      lorebook_entries: length(lorebook_entries),
      total_playtime: calculate_total_playtime(sessions),
      last_activity: get_last_campaign_activity(sessions)
    }
  end
  
  # Private Helper Functions
  
  defp convert_sillytavern_character(char_data) do
    %{
      name: char_data["name"] || "Unknown",
      race: char_data["race"] || "Human",
      class: char_data["class"] || "Fighter",
      level: char_data["level"] || 1,
      background: char_data["background"],
      personality_traits: char_data["personality"] || char_data["description"],
      ideals: char_data["ideals"],
      bonds: char_data["bonds"],
      flaws: char_data["flaws"],
      
      # Default D&D stats if not provided
      strength: char_data["strength"] || 10,
      dexterity: char_data["dexterity"] || 10,
      constitution: char_data["constitution"] || 10,
      intelligence: char_data["intelligence"] || 10,
      wisdom: char_data["wisdom"] || 10,
      charisma: char_data["charisma"] || 10,
      
      max_hp: char_data["max_hp"] || char_data["hit_points"] || 8,
      current_hp: char_data["current_hp"] || char_data["hit_points"] || 8,
      armor_class: char_data["armor_class"] || 10,
      
      inventory: char_data["inventory"] || [],
      features: char_data["features"] || char_data["abilities"] || [],
      status_effects: []
    }
  end
  
  defp convert_sillytavern_lorebook(lorebook_data, campaign_name) do
    entries = lorebook_data["entries"] || []
    
    Enum.map(entries, fn entry ->
      %{
        title: entry["title"] || entry["key"] || "Untitled",
        content: entry["content"] || entry["description"] || "",
        keywords: String.split(entry["key"] || "", ",") |> Enum.map(&String.trim/1),
        priority: entry["priority"] || entry["order"] || 1,
        category: entry["category"],
        campaign_name: campaign_name,
        insertion_order: entry["order"] || 100,
        token_budget: entry["token_budget"] || 500,
        active: entry["enabled"] != false,
        trigger_conditions: entry["conditions"] || %{},
        created_by: "sillytavern_import"
      }
    end)
  end
  
  defp convert_to_sillytavern_character(character) do
    %{
      "name" => character.name,
      "race" => character.race,
      "class" => character.class,
      "level" => character.level,
      "background" => character.background,
      "personality" => character.personality_traits,
      "ideals" => character.ideals,
      "bonds" => character.bonds,
      "flaws" => character.flaws,
      
      "strength" => character.strength,
      "dexterity" => character.dexterity,
      "constitution" => character.constitution,
      "intelligence" => character.intelligence,
      "wisdom" => character.wisdom,
      "charisma" => character.charisma,
      
      "hit_points" => character.max_hp,
      "current_hp" => character.current_hp,
      "armor_class" => character.armor_class,
      
      "inventory" => character.inventory,
      "abilities" => character.features
    }
    |> Jason.encode!()
  end
  
  defp calculate_total_playtime(sessions) do
    sessions
    |> Enum.reduce(0, fn session, acc ->
      if session.session_start && session.session_end do
        duration = DateTime.diff(session.session_end, session.session_start, :minute)
        acc + duration
      else
        acc
      end
    end)
  end
  
  defp get_last_campaign_activity(sessions) do
    sessions
    |> Enum.map(& &1.last_activity)
    |> Enum.reject(&is_nil/1)
    |> Enum.max(DateTime, fn -> nil end)
  end
end