defmodule AgenticDm.CLI do
  @moduledoc """
  Command-line interface for the Agentic D&D DM system.
  Provides interactive session management and configuration.
  """
  
  require Logger
  alias AgenticDm.{DmAgent, GameState}
  
  @commands %{
    "start" => "Start a new campaign or resume an existing session",
    "list" => "List campaigns, sessions, or characters",
    "import" => "Import character or lorebook data",
    "export" => "Export character or campaign data", 
    "stats" => "Show campaign statistics",
    "help" => "Show available commands",
    "quit" => "Exit the application"
  }
  
  @session_commands %{
    "/help" => "Show session commands",
    "/info" => "Display current session information",
    "/characters" => "List active characters",
    "/stats" => "Show character stats",
    "/save" => "Save current session",
    "/quit" => "Save and exit session",
    "/exit" => "Save and exit session"
  }
  
  def main(args \\ []) do
    IO.puts("""
    
    ╔═══════════════════════════════════════╗
    ║        Agentic D&D Dungeon Master     ║
    ║              Version 0.1.0            ║
    ╚═══════════════════════════════════════╝
    
    Welcome to the AI-powered Dungeon Master!
    Type 'help' for available commands.
    """)
    
    case args do
      [] -> 
        interactive_mode()
      ["start" | rest] -> 
        handle_start_command(rest)
      [command | rest] -> 
        handle_command(command, rest)
    end
  end
  
  def interactive_mode do
    case get_user_input("agentic-dm> ") do
      "quit" -> 
        IO.puts("Goodbye!")
        
      "help" -> 
        show_help()
        interactive_mode()
        
      command_line ->
        case String.split(command_line, " ", trim: true) do
          [] -> interactive_mode()
          [command | args] ->
            handle_command(command, args)
            interactive_mode()
        end
    end
  end
  
  # Command Handlers
  
  defp handle_command("start", args) do
    handle_start_command(args)
  end
  
  defp handle_command("list", ["campaigns"]) do
    list_campaigns()
  end
  
  defp handle_command("list", ["sessions"]) do
    list_sessions()
  end
  
  defp handle_command("list", ["sessions", campaign_name]) do
    list_campaign_sessions(campaign_name)
  end
  
  defp handle_command("list", ["characters"]) do
    list_characters()
  end
  
  defp handle_command("import", ["character", file_path]) do
    import_character_file(file_path)
  end
  
  defp handle_command("import", ["lorebook", file_path, campaign_name]) do
    import_lorebook_file(file_path, campaign_name)
  end
  
  defp handle_command("export", ["character", character_name]) do
    export_character(character_name)
  end
  
  defp handle_command("stats", [campaign_name]) do
    show_campaign_stats(campaign_name)
  end
  
  defp handle_command("help", _) do
    show_help()
  end
  
  defp handle_command(unknown_command, _) do
    IO.puts("Unknown command: #{unknown_command}")
    IO.puts("Type 'help' for available commands.")
  end
  
  # Start Command Handler
  
  defp handle_start_command(args) do
    case args do
      [campaign_name] ->
        start_new_campaign(campaign_name)
      [campaign_name, "--session", session_id] ->
        resume_session(campaign_name, session_id)
      [] ->
        IO.puts("Usage: start <campaign_name> [--session <session_id>]")
      _ ->
        IO.puts("Invalid arguments for start command")
    end
  end
  
  defp start_new_campaign(campaign_name) do
    IO.puts("Starting new campaign: #{campaign_name}")
    
    # Generate unique session ID
    session_id = generate_session_id()
    
    # Start the DM Agent
    case DynamicSupervisor.start_child(
      AgenticDm.DmSupervisor, 
      {DmAgent, [name: {:via, Registry, {AgenticDm.SessionRegistry, session_id}}]}
    ) do
      {:ok, pid} ->
        case DmAgent.start_session(pid, campaign_name) do
          {:ok, _game_session} ->
            IO.puts("✅ Campaign started successfully!")
            IO.puts("Session ID: #{session_id}")
            run_game_session(pid, session_id)
          {:error, reason} ->
            IO.puts("❌ Failed to start campaign: #{inspect(reason)}")
        end
      
      {:error, reason} ->
        IO.puts("❌ Failed to start DM Agent: #{inspect(reason)}")
    end
  end
  
  defp resume_session(campaign_name, session_id) do
    IO.puts("Resuming session: #{session_id} for campaign: #{campaign_name}")
    
    case DynamicSupervisor.start_child(
      AgenticDm.DmSupervisor, 
      {DmAgent, [name: {:via, Registry, {AgenticDm.SessionRegistry, session_id}}]}
    ) do
      {:ok, pid} ->
        case DmAgent.load_session(pid, session_id) do
          {:ok, _game_session} ->
            IO.puts("✅ Session resumed successfully!")
            run_game_session(pid, session_id)
          {:error, :not_found} ->
            IO.puts("❌ Session not found. Starting new campaign instead.")
            DmAgent.start_session(pid, campaign_name)
            run_game_session(pid, session_id)
          {:error, reason} ->
            IO.puts("❌ Failed to resume session: #{inspect(reason)}")
        end
      
      {:error, reason} ->
        IO.puts("❌ Failed to start DM Agent: #{inspect(reason)}")
    end
  end
  
  # Game Session Loop
  
  defp run_game_session(dm_pid, session_id) do
    IO.puts("""
    
    🎲 Session started! You can now interact with the DM.
    
    Session commands:
    #{format_session_commands()}
    
    Simply type your actions in natural language, and the AI DM will respond.
    """)
    
    game_loop(dm_pid, session_id)
  end
  
  defp game_loop(dm_pid, session_id) do
    case get_user_input("> ") do
      input when input in ["/quit", "/exit"] ->
        IO.puts("Saving and exiting session...")
        DmAgent.stop_session(dm_pid)
        IO.puts("Session saved. Goodbye!")
      
      "/help" ->
        show_session_help()
        game_loop(dm_pid, session_id)
      
      "/info" ->
        show_session_info(dm_pid)
        game_loop(dm_pid, session_id)
      
      "/characters" ->
        show_session_characters(dm_pid)
        game_loop(dm_pid, session_id)
      
      "/save" ->
        case DmAgent.save_session(dm_pid) do
          :ok -> IO.puts("✅ Session saved!")
          {:error, reason} -> IO.puts("❌ Failed to save: #{inspect(reason)}")
        end
        game_loop(dm_pid, session_id)
      
      "" ->
        game_loop(dm_pid, session_id)
      
      user_input ->
        handle_user_input(dm_pid, user_input)
        game_loop(dm_pid, session_id)
    end
  end
  
  defp handle_user_input(dm_pid, input) do
    IO.puts("\n🎯 Processing your action...")
    
    case DmAgent.process_input(dm_pid, input) do
      {:ok, response} ->
        IO.puts("\n🧙 #{format_dm_response(response)}")
      
      {:error, reason} ->
        IO.puts("\n❌ Error: #{inspect(reason)}")
        IO.puts("Please try again or type /help for assistance.")
    end
  end
  
  # List Commands
  
  defp list_campaigns do
    IO.puts("📚 Available Campaigns:")
    
    # This is a simplified version - in a real implementation you'd query the database
    case GameState.list_world_states() do
      [] ->
        IO.puts("No campaigns found.")
      
      world_states ->
        Enum.each(world_states, fn ws ->
          IO.puts("  • #{ws.campaign_name} - #{ws.name}")
        end)
    end
  end
  
  defp list_sessions do
    IO.puts("🎮 Active Sessions:")
    
    case GameState.list_active_sessions() do
      [] ->
        IO.puts("No active sessions.")
      
      sessions ->
        Enum.each(sessions, fn session ->
          IO.puts("  • #{session.session_id} - #{session.campaign_name} (#{session.status})")
        end)
    end
  end
  
  defp list_campaign_sessions(campaign_name) do
    IO.puts("🎮 Sessions for #{campaign_name}:")
    
    case GameState.list_sessions_by_campaign(campaign_name) do
      [] ->
        IO.puts("No sessions found for this campaign.")
      
      sessions ->
        Enum.each(sessions, fn session ->
          status_icon = if session.status == "active", do: "🟢", else: "🔵"
          IO.puts("  #{status_icon} #{session.session_id} - #{session.status}")
        end)
    end
  end
  
  defp list_characters do
    IO.puts("⚔️  Active Characters:")
    
    case GameState.list_active_characters() do
      [] ->
        IO.puts("No characters found.")
      
      characters ->
        Enum.each(characters, fn char ->
          IO.puts("  • #{char.name} - #{char.race} #{char.class} (Level #{char.level})")
        end)
    end
  end
  
  # Import/Export Commands
  
  defp import_character_file(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        case GameState.import_sillytavern_character(content) do
          {:ok, character} ->
            IO.puts("✅ Successfully imported character: #{character.name}")
          {:error, reason} ->
            IO.puts("❌ Failed to import character: #{inspect(reason)}")
        end
      
      {:error, reason} ->
        IO.puts("❌ Failed to read file: #{inspect(reason)}")
    end
  end
  
  defp import_lorebook_file(file_path, campaign_name) do
    case File.read(file_path) do
      {:ok, content} ->
        case GameState.import_sillytavern_lorebook(content, campaign_name) do
          {:ok, count} ->
            IO.puts("✅ Successfully imported #{count} lorebook entries")
          {:error, reason} ->
            IO.puts("❌ Failed to import lorebook: #{inspect(reason)}")
        end
      
      {:error, reason} ->
        IO.puts("❌ Failed to read file: #{inspect(reason)}")
    end
  end
  
  defp export_character(character_name) do
    case GameState.get_character_by_name(character_name) do
      {:ok, character} ->
        case GameState.export_character(character.id, :json) do
          {:ok, json_data} ->
            filename = "#{String.downcase(character_name)}_export.json"
            File.write!(filename, json_data)
            IO.puts("✅ Character exported to #{filename}")
          {:error, reason} ->
            IO.puts("❌ Export failed: #{inspect(reason)}")
        end
      
      {:error, :not_found} ->
        IO.puts("❌ Character not found: #{character_name}")
    end
  end
  
  # Stats and Info
  
  defp show_campaign_stats(campaign_name) do
    case GameState.get_campaign_stats(campaign_name) do
      stats ->
        IO.puts("""
        
        📊 Campaign Statistics for #{campaign_name}:
        
        Sessions: #{stats.total_sessions} total, #{stats.active_sessions} active
        Characters: #{stats.total_characters} total, #{stats.active_characters} active  
        Lorebook Entries: #{stats.lorebook_entries}
        Total Playtime: #{stats.total_playtime} minutes
        Last Activity: #{format_datetime(stats.last_activity)}
        """)
    end
  end
  
  defp show_session_info(dm_pid) do
    case DmAgent.get_session_info(dm_pid) do
      info ->
        IO.puts("""
        
        📋 Current Session Info:
        
        Session ID: #{info.session_id}
        Campaign: #{info.campaign_name}
        Status: #{info.status}
        Characters: #{info.character_count}
        World State: #{info.world_state}
        Last Activity: #{format_datetime(info.last_activity)}
        """)
    end
  end
  
  defp show_session_characters(_dm_pid) do
    # This would require extending the DM Agent to return character info
    IO.puts("📋 Session Characters: (Not implemented yet)")
  end
  
  # Help Text
  
  defp show_help do
    IO.puts("""
    
    📖 Available Commands:
    
    #{format_commands(@commands)}
    
    Examples:
      start "Lost Mines of Phandelver"
      start "Lost Mines of Phandelver" --session abc123
      list campaigns
      list sessions
      import character ./characters/gandalf.json
      import lorebook ./worldinfo.json "My Campaign"
      stats "Lost Mines of Phandelver"
    """)
  end
  
  defp show_session_help do
    IO.puts("""
    
    📖 Session Commands:
    
    #{format_commands(@session_commands)}
    
    You can also use natural language to interact with the DM:
      "I search the room for traps"
      "I want to persuade the guard"
      "I cast fireball at the goblins"
    """)
  end
  
  # Utility Functions
  
  defp get_user_input(prompt) do
    case IO.gets(prompt) do
      :eof -> "quit"
      {:error, _reason} -> "quit"
      input when is_binary(input) -> String.trim(input)
    end
  end
  
  defp generate_session_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end
  
  defp format_commands(commands) do
    commands
    |> Enum.map(fn {cmd, desc} -> "    #{String.pad_trailing(cmd, 12)} - #{desc}" end)
    |> Enum.join("\n")
  end
  
  defp format_session_commands do
    @session_commands
    |> Enum.map(fn {cmd, desc} -> "    #{cmd} - #{desc}" end)
    |> Enum.join("\n")
  end
  
  defp format_dm_response(response) do
    # Add some basic formatting to make responses more readable
    response
    |> String.replace(~r/\*([^*]+)\*/, "\\1")  # Remove markdown emphasis
    |> String.replace(~r/^/, "DM: ", global: false)  # Add DM prefix
  end
  
  defp format_datetime(nil), do: "Never"
  defp format_datetime(datetime) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_string()
  end
end