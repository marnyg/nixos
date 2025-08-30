defmodule AgenticDm.DmAgent do
  use GenServer
  require Logger
  
  alias AgenticDm.{LlmClient, GameState, LorebookManager, DndTools}
  alias AgenticDm.Schemas.GameSession

  @moduledoc """
  The DM Agent is the main orchestrator for D&D game sessions.
  It manages game state, coordinates with the LLM, and handles tool executions.
  """

  defstruct [
    :session_id,
    :game_session,
    :world_state,
    :characters,
    :llm_client,
    :lorebook_manager,
    :tools,
    :last_activity
  ]

  # Client API

  def start_link(opts \\ []) do
    {session_id, opts} = Keyword.pop(opts, :session_id)
    GenServer.start_link(__MODULE__, session_id, opts)
  end

  def start_session(pid, campaign_name, opts \\ []) do
    GenServer.call(pid, {:start_session, campaign_name, opts})
  end

  def load_session(pid, session_id) do
    GenServer.call(pid, {:load_session, session_id})
  end

  def process_input(pid, user_input) do
    GenServer.call(pid, {:process_input, user_input}, 30_000)
  end

  def add_character(pid, character_data) do
    GenServer.call(pid, {:add_character, character_data})
  end

  def get_session_info(pid) do
    GenServer.call(pid, :get_session_info)
  end

  def save_session(pid) do
    GenServer.call(pid, :save_session)
  end

  def stop_session(pid) do
    GenServer.call(pid, :stop_session)
  end

  # Server Callbacks

  @impl true
  def init(session_id) do
    Logger.info("Starting DM Agent for session: #{session_id}")
    
    state = %__MODULE__{
      session_id: session_id,
      llm_client: LlmClient.new(),
      tools: DndTools.new(),
      last_activity: DateTime.utc_now()
    }
    
    {:ok, state}
  end

  @impl true
  def handle_call({:start_session, campaign_name, opts}, _from, state) do
    Logger.info("Starting new session for campaign: #{campaign_name}")
    
    with {:ok, world_state} <- GameState.create_world_state_for_campaign(campaign_name),
         {:ok, game_session} <- GameState.create_session(state.session_id, campaign_name, world_state.id, opts) do
      
      lorebook_manager = LorebookManager.new(campaign_name)
      
      new_state = %{state |
        game_session: game_session,
        world_state: world_state,
        characters: [],
        lorebook_manager: lorebook_manager,
        last_activity: DateTime.utc_now()
      }
      
      {:reply, {:ok, game_session}, new_state}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:load_session, session_id}, _from, state) do
    Logger.info("Loading existing session: #{session_id}")
    
    with {:ok, game_session} <- GameState.get_session(session_id),
         {:ok, world_state} <- GameState.get_world_state(game_session.world_state_id),
         {:ok, characters} <- GameState.get_session_characters(game_session.character_ids) do
      
      lorebook_manager = LorebookManager.new(game_session.campaign_name)
      
      new_state = %{state |
        session_id: session_id,
        game_session: game_session,
        world_state: world_state,
        characters: characters,
        lorebook_manager: lorebook_manager,
        last_activity: DateTime.utc_now()
      }
      
      {:reply, {:ok, game_session}, new_state}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:process_input, user_input}, _from, state) do
    Logger.info("Processing user input: #{String.slice(user_input, 0, 100)}...")
    
    case generate_response(state, user_input) do
      {:ok, response, updated_state} ->
        {:reply, {:ok, response}, updated_state}
      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:add_character, character_data}, _from, state) do
    case GameState.create_character(character_data) do
      {:ok, character} ->
        updated_characters = [character | state.characters]
        updated_session = GameSession.add_message(
          state.game_session, 
          "system", 
          "Character #{character.name} has joined the session."
        )
        
        new_state = %{state |
          characters: updated_characters,
          game_session: updated_session,
          last_activity: DateTime.utc_now()
        }
        
        {:reply, {:ok, character}, new_state}
      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:get_session_info, _from, state) do
    info = %{
      session_id: state.session_id,
      campaign_name: state.game_session && state.game_session.campaign_name,
      status: state.game_session && state.game_session.status,
      character_count: length(state.characters || []),
      world_state: state.world_state && state.world_state.name,
      last_activity: state.last_activity
    }
    
    {:reply, info, state}
  end

  @impl true
  def handle_call(:save_session, _from, state) do
    case save_current_state(state) do
      {:ok, _} -> {:reply, :ok, state}
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:stop_session, _from, state) do
    Logger.info("Stopping session: #{state.session_id}")
    
    case save_current_state(state) do
      {:ok, _} ->
        updated_session = GameSession.complete_session(state.game_session)
        GameState.update_session(updated_session)
        {:stop, :normal, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  # Private Functions

  defp generate_response(state, user_input) do
    with {:ok, context} <- build_context(state, user_input),
         {:ok, llm_response} <- LlmClient.generate_response(state.llm_client, context),
         {:ok, updated_state} <- process_llm_response(state, user_input, llm_response) do
      {:ok, llm_response.content, updated_state}
    end
  end

  defp build_context(state, user_input) do
    base_context = %{
      system_prompt: build_system_prompt(state),
      conversation_history: state.game_session.conversation_history,
      user_message: user_input,
      available_tools: DndTools.get_available_tools(state.tools)
    }
    
    case LorebookManager.inject_context(state.lorebook_manager, base_context) do
      {:ok, enhanced_context} -> {:ok, enhanced_context}
      error -> error
    end
  end

  defp build_system_prompt(state) do
    """
    You are an expert Dungeon Master running a D&D campaign called "#{state.game_session.campaign_name}".
    
    Current World State:
    - Location: #{state.world_state.current_location || "Unknown"}
    - Time: #{state.world_state.time_of_day}
    - Weather: #{state.world_state.weather}
    - Season: #{state.world_state.season}
    
    Active Characters:
    #{format_character_list(state.characters)}
    
    You have access to the following tools for managing the game:
    - roll_dice: Roll dice with D&D mechanics
    - get_character_stats: Query character information  
    - update_character_stat: Modify character attributes
    - manage_inventory: Add/remove items from character inventory
    - apply_status_effect: Apply temporary effects to characters
    - update_world_state: Modify world elements like locations, NPCs, events
    - query_world_info: Retrieve information about the world
    - add_lorebook_entry: Create new lore entries dynamically
    
    Guidelines:
    1. Respond as an engaging, creative Dungeon Master
    2. Use tools automatically when appropriate (dice rolls, stat changes, etc.)
    3. Maintain consistency with the world state and character information
    4. Create immersive narratives that respond to player actions
    5. Enforce D&D rules through the available tools
    6. Update world state as events unfold
    """
  end

  defp format_character_list([]), do: "No active characters"
  defp format_character_list(characters) do
    characters
    |> Enum.map(fn char ->
      "- #{char.name} (#{char.race} #{char.class}, Level #{char.level})"
    end)
    |> Enum.join("\n")
  end

  defp process_llm_response(state, user_input, llm_response) do
    # Add user message to conversation history
    updated_session = GameSession.add_message(state.game_session, "user", user_input)
    
    # Process any tool calls from the LLM response
    case process_tool_calls(state, llm_response.tool_calls || []) do
      {:ok, tool_results, updated_game_state} ->
        # Add assistant response to conversation history
        final_session = GameSession.add_message(
          updated_session, 
          "assistant", 
          llm_response.content,
          %{tool_calls: llm_response.tool_calls, tool_results: tool_results}
        )
        
        updated_state = %{state |
          game_session: final_session,
          world_state: updated_game_state.world_state || state.world_state,
          characters: updated_game_state.characters || state.characters,
          last_activity: DateTime.utc_now()
        }
        
        {:ok, updated_state}
      error ->
        error
    end
  end

  defp process_tool_calls(state, tool_calls) do
    game_state = %{
      world_state: state.world_state,
      characters: state.characters,
      session: state.game_session
    }
    
    DndTools.execute_tools(state.tools, tool_calls, game_state)
  end

  defp save_current_state(state) do
    with :ok <- GameState.update_session(state.game_session),
         :ok <- GameState.update_world_state(state.world_state),
         :ok <- save_characters(state.characters) do
      {:ok, :saved}
    end
  end

  defp save_characters(characters) do
    Enum.reduce_while(characters, :ok, fn character, acc ->
      case GameState.update_character(character) do
        {:ok, _} -> {:cont, acc}
        error -> {:halt, error}
      end
    end)
  end
end