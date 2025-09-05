defmodule AgenticDm.DndTools do
  @moduledoc """
  D&D tool system for handling dice rolls, character management, and world state updates.
  Implements the Model Context Protocol (MCP) style tool interface.
  """
  
  require Logger
  
  defstruct [:tools]
  
  def new do
    %__MODULE__{
      tools: register_tools()
    }
  end

  def get_available_tools(dnd_tools) do
    Map.values(dnd_tools.tools)
  end

  def execute_tools(dnd_tools, tool_calls, game_state) do
    Logger.info("Executing #{length(tool_calls)} tool calls")
    
    results = Enum.map(tool_calls, fn tool_call ->
      execute_tool(dnd_tools, tool_call, game_state)
    end)
    
    # Check if any tools failed
    case Enum.find(results, fn {status, _} -> status == :error end) do
      nil ->
        # All successful - extract results and updated game state
        tool_results = Enum.map(results, fn {:ok, result} -> result[:result] end)
        final_game_state = 
          results
          |> Enum.map(fn {:ok, result} -> result[:game_state] end)
          |> merge_game_states(game_state)
        
        {:ok, tool_results, final_game_state}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Tool Definitions

  defp register_tools do
    %{
      "roll_dice" => %{
        name: "roll_dice",
        description: "Roll dice with D&D mechanics including advantage/disadvantage",
        parameters: %{
          type: "object",
          properties: %{
            dice_expression: %{
              type: "string", 
              description: "Dice to roll (e.g., '1d20', '3d6', '2d8+5')"
            },
            advantage: %{
              type: "boolean", 
              description: "Roll with advantage (roll twice, take higher)"
            },
            disadvantage: %{
              type: "boolean", 
              description: "Roll with disadvantage (roll twice, take lower)"
            },
            modifier: %{
              type: "integer", 
              description: "Additional modifier to add to the roll"
            },
            description: %{
              type: "string", 
              description: "Description of what this roll is for"
            }
          },
          required: ["dice_expression"]
        }
      },
      
      "get_character_stats" => %{
        name: "get_character_stats",
        description: "Query character information and statistics",
        parameters: %{
          type: "object",
          properties: %{
            character_name: %{
              type: "string", 
              description: "Name of the character to query"
            },
            stat_type: %{
              type: "string", 
              description: "Specific stat to query (optional, returns all if not specified)"
            }
          },
          required: ["character_name"]
        }
      },
      
      "update_character_stat" => %{
        name: "update_character_stat",
        description: "Modify character attributes and statistics",
        parameters: %{
          type: "object",
          properties: %{
            character_name: %{
              type: "string", 
              description: "Name of the character to update"
            },
            stat_name: %{
              type: "string", 
              description: "Name of the stat to update (e.g., 'current_hp', 'strength')"
            },
            new_value: %{
              type: "integer", 
              description: "New value for the stat"
            },
            operation: %{
              type: "string", 
              description: "Operation to perform: 'set', 'add', 'subtract'",
              enum: ["set", "add", "subtract"]
            }
          },
          required: ["character_name", "stat_name", "new_value"]
        }
      },
      
      "manage_inventory" => %{
        name: "manage_inventory",
        description: "Add or remove items from character inventory",
        parameters: %{
          type: "object",
          properties: %{
            character_name: %{
              type: "string", 
              description: "Name of the character"
            },
            action: %{
              type: "string", 
              description: "Action to perform: 'add' or 'remove'",
              enum: ["add", "remove"]
            },
            item: %{
              type: "object",
              description: "Item to add/remove",
              properties: %{
                name: %{type: "string"},
                quantity: %{type: "integer"},
                description: %{type: "string"},
                weight: %{type: "number"},
                value: %{type: "integer"}
              },
              required: ["name", "quantity"]
            }
          },
          required: ["character_name", "action", "item"]
        }
      },
      
      "apply_status_effect" => %{
        name: "apply_status_effect",
        description: "Apply temporary effects to characters",
        parameters: %{
          type: "object",
          properties: %{
            character_name: %{
              type: "string", 
              description: "Name of the character"
            },
            effect: %{
              type: "object",
              description: "Status effect to apply",
              properties: %{
                name: %{type: "string"},
                description: %{type: "string"},
                duration: %{type: "integer", description: "Duration in rounds/minutes"},
                duration_type: %{type: "string", enum: ["rounds", "minutes", "hours"]},
                effects: %{type: "object", description: "Stat modifiers and other effects"}
              },
              required: ["name", "description", "duration"]
            },
            action: %{
              type: "string", 
              description: "Action: 'apply' or 'remove'",
              enum: ["apply", "remove"]
            }
          },
          required: ["character_name", "effect", "action"]
        }
      },
      
      "update_world_state" => %{
        name: "update_world_state",
        description: "Modify world elements like locations, NPCs, events",
        parameters: %{
          type: "object",
          properties: %{
            element_type: %{
              type: "string", 
              description: "Type of world element to update",
              enum: ["location", "npc", "event", "quest", "story_flag", "environment"]
            },
            action: %{
              type: "string", 
              description: "Action to perform: 'add', 'update', 'remove'",
              enum: ["add", "update", "remove"]
            },
            data: %{
              type: "object", 
              description: "Data for the world element"
            }
          },
          required: ["element_type", "action", "data"]
        }
      },
      
      "query_world_info" => %{
        name: "query_world_info",
        description: "Retrieve information about the world state",
        parameters: %{
          type: "object",
          properties: %{
            query_type: %{
              type: "string", 
              description: "Type of information to query",
              enum: ["location", "npc", "event", "quest", "story_flag", "all"]
            },
            filter: %{
              type: "object", 
              description: "Optional filter criteria"
            }
          },
          required: ["query_type"]
        }
      }
    }
  end

  # Tool Execution Functions

  defp execute_tool(dnd_tools, tool_call, game_state) do
    tool_name = tool_call.function.name
    arguments = tool_call.function.arguments
    
    Logger.info("Executing tool: #{tool_name} with args: #{inspect(arguments)}")
    
    case Map.get(dnd_tools.tools, tool_name) do
      nil ->
        {:error, "Unknown tool: #{tool_name}"}
      
      _tool_def ->
        case tool_name do
          "roll_dice" -> handle_roll_dice(arguments, game_state)
          "get_character_stats" -> handle_get_character_stats(arguments, game_state)
          "update_character_stat" -> handle_update_character_stat(arguments, game_state)
          "manage_inventory" -> handle_manage_inventory(arguments, game_state)
          "apply_status_effect" -> handle_apply_status_effect(arguments, game_state)
          "update_world_state" -> handle_update_world_state(arguments, game_state)
          "query_world_info" -> handle_query_world_info(arguments, game_state)
          _ -> {:error, "Tool not implemented: #{tool_name}"}
        end
    end
  end

  defp handle_roll_dice(args, game_state) do
    dice_expr = args["dice_expression"]
    advantage = args["advantage"] || false
    disadvantage = args["disadvantage"] || false
    modifier = args["modifier"] || 0
    description = args["description"] || "Dice roll"
    
    case roll_dice_expression(dice_expr, advantage, disadvantage, modifier) do
      {:ok, result} ->
        {:ok, %{
          result: %{
            expression: dice_expr,
            rolls: result.rolls,
            total: result.total,
            description: description,
            advantage: advantage,
            disadvantage: disadvantage,
            modifier: modifier
          },
          game_state: game_state
        }}
      error -> error
    end
  end

  defp handle_get_character_stats(args, game_state) do
    character_name = args["character_name"]
    stat_type = args["stat_type"]
    
    case find_character(game_state.characters, character_name) do
      nil ->
        {:error, "Character '#{character_name}' not found"}
      
      character ->
        stats = if stat_type do
          %{stat_type => Map.get(character, String.to_existing_atom(stat_type))}
        else
          character |> Map.from_struct() |> Map.drop([:__meta__])
        end
        
        {:ok, %{
          result: %{character: character_name, stats: stats},
          game_state: game_state
        }}
    end
  end

  defp handle_update_character_stat(args, game_state) do
    character_name = args["character_name"]
    stat_name = args["stat_name"]
    new_value = args["new_value"]
    operation = args["operation"] || "set"
    
    case find_character(game_state.characters, character_name) do
      nil ->
        {:error, "Character '#{character_name}' not found"}
      
      character ->
        case update_character_stat(character, stat_name, new_value, operation) do
          {:ok, updated_character} ->
            updated_characters = update_character_in_list(
              game_state.characters, 
              character_name, 
              updated_character
            )
            
            {:ok, %{
              result: %{
                character: character_name,
                stat: stat_name,
                old_value: Map.get(character, String.to_existing_atom(stat_name)),
                new_value: Map.get(updated_character, String.to_existing_atom(stat_name)),
                operation: operation
              },
              game_state: %{game_state | characters: updated_characters}
            }}
          error -> error
        end
    end
  end

  defp handle_manage_inventory(args, game_state) do
    character_name = args["character_name"]
    action = args["action"]
    item = args["item"]
    
    case find_character(game_state.characters, character_name) do
      nil ->
        {:error, "Character '#{character_name}' not found"}
      
      character ->
        case manage_character_inventory(character, action, item) do
          {:ok, updated_character} ->
            updated_characters = update_character_in_list(
              game_state.characters, 
              character_name, 
              updated_character
            )
            
            {:ok, %{
              result: %{
                character: character_name,
                action: action,
                item: item,
                success: true
              },
              game_state: %{game_state | characters: updated_characters}
            }}
          error -> error
        end
    end
  end

  defp handle_apply_status_effect(args, game_state) do
    character_name = args["character_name"]
    effect = args["effect"]
    action = args["action"]
    
    case find_character(game_state.characters, character_name) do
      nil ->
        {:error, "Character '#{character_name}' not found"}
      
      character ->
        case apply_character_status_effect(character, effect, action) do
          {:ok, updated_character} ->
            updated_characters = update_character_in_list(
              game_state.characters, 
              character_name, 
              updated_character
            )
            
            {:ok, %{
              result: %{
                character: character_name,
                effect: effect["name"],
                action: action,
                success: true
              },
              game_state: %{game_state | characters: updated_characters}
            }}
          error -> error
        end
    end
  end

  defp handle_update_world_state(args, game_state) do
    element_type = args["element_type"]
    action = args["action"]
    data = args["data"]
    
    case update_world_element(game_state.world_state, element_type, action, data) do
      {:ok, updated_world_state} ->
        {:ok, %{
          result: %{
            element_type: element_type,
            action: action,
            success: true
          },
          game_state: %{game_state | world_state: updated_world_state}
        }}
      error -> error
    end
  end

  defp handle_query_world_info(args, game_state) do
    query_type = args["query_type"]
    filter = args["filter"] || %{}
    
    result = query_world_information(game_state.world_state, query_type, filter)
    
    {:ok, %{
      result: %{query_type: query_type, data: result},
      game_state: game_state
    }}
  end

  # Helper Functions

  defp roll_dice_expression(dice_expr, advantage, disadvantage, modifier) do
    case parse_dice_expression(dice_expr) do
      {:ok, {count, sides}} ->
        base_rolls = Enum.map(1..count, fn _ -> :rand.uniform(sides) end)
        
        final_rolls = cond do
          advantage && !disadvantage ->
            # Roll twice for each die, take the higher
            advantage_rolls = Enum.map(1..count, fn _ -> :rand.uniform(sides) end)
            Enum.zip_with(base_rolls, advantage_rolls, &max/2)
          
          disadvantage && !advantage ->
            # Roll twice for each die, take the lower
            disadvantage_rolls = Enum.map(1..count, fn _ -> :rand.uniform(sides) end)
            Enum.zip_with(base_rolls, disadvantage_rolls, &min/2)
          
          true ->
            base_rolls
        end
        
        total = Enum.sum(final_rolls) + modifier
        
        {:ok, %{
          rolls: final_rolls,
          total: total,
          base_total: Enum.sum(final_rolls),
          modifier: modifier
        }}
      
      error -> error
    end
  end

  defp parse_dice_expression(expr) do
    # Simple regex for dice expressions like "1d20", "3d6", "2d8+5"
    case Regex.run(~r/^(\d+)d(\d+)(?:\+(\d+))?$/, String.downcase(expr)) do
      [_, count_str, sides_str] ->
        {:ok, {String.to_integer(count_str), String.to_integer(sides_str)}}
      
      [_, count_str, sides_str, _modifier_str] ->
        {:ok, {String.to_integer(count_str), String.to_integer(sides_str)}}
      
      nil ->
        {:error, "Invalid dice expression: #{expr}"}
    end
  end

  defp find_character(characters, name) do
    Enum.find(characters, fn char -> 
      String.downcase(char.name) == String.downcase(name) 
    end)
  end

  defp update_character_stat(character, stat_name, new_value, operation) do
    stat_atom = String.to_existing_atom(stat_name)
    current_value = Map.get(character, stat_atom)
    
    final_value = case operation do
      "set" -> new_value
      "add" -> (current_value || 0) + new_value
      "subtract" -> (current_value || 0) - new_value
      _ -> new_value
    end
    
    {:ok, Map.put(character, stat_atom, final_value)}
  rescue
    ArgumentError -> {:error, "Unknown stat: #{stat_name}"}
  end

  defp update_character_in_list(characters, character_name, updated_character) do
    Enum.map(characters, fn char ->
      if String.downcase(char.name) == String.downcase(character_name) do
        updated_character
      else
        char
      end
    end)
  end

  defp manage_character_inventory(character, "add", item) do
    new_inventory = [item | character.inventory]
    {:ok, %{character | inventory: new_inventory}}
  end

  defp manage_character_inventory(character, "remove", item) do
    updated_inventory = remove_item_from_inventory(character.inventory, item)
    {:ok, %{character | inventory: updated_inventory}}
  end

  defp remove_item_from_inventory(inventory, item_to_remove) do
    item_name = item_to_remove["name"]
    quantity_to_remove = item_to_remove["quantity"] || 1
    
    Enum.reduce(inventory, [], fn item, acc ->
      if item["name"] == item_name do
        current_quantity = item["quantity"] || 1
        remaining = current_quantity - quantity_to_remove
        
        if remaining > 0 do
          [Map.put(item, "quantity", remaining) | acc]
        else
          acc
        end
      else
        [item | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp apply_character_status_effect(character, effect, "apply") do
    new_effects = [effect | character.status_effects]
    {:ok, %{character | status_effects: new_effects}}
  end

  defp apply_character_status_effect(character, effect, "remove") do
    effect_name = effect["name"]
    updated_effects = Enum.reject(character.status_effects, fn e -> 
      e["name"] == effect_name 
    end)
    {:ok, %{character | status_effects: updated_effects}}
  end

  defp update_world_element(world_state, "location", "add", data) do
    {:ok, AgenticDm.Schemas.WorldState.add_location(world_state, data)}
  end

  defp update_world_element(world_state, "npc", "add", data) do
    {:ok, AgenticDm.Schemas.WorldState.add_npc(world_state, data)}
  end

  defp update_world_element(world_state, "event", "add", data) do
    {:ok, AgenticDm.Schemas.WorldState.add_event(world_state, data)}
  end

  defp update_world_element(world_state, "quest", "add", data) do
    {:ok, AgenticDm.Schemas.WorldState.add_quest(world_state, data)}
  end

  defp update_world_element(world_state, "story_flag", "add", data) do
    flag_name = data["name"]
    flag_value = data["value"]
    {:ok, AgenticDm.Schemas.WorldState.set_story_flag(world_state, flag_name, flag_value)}
  end

  defp update_world_element(_world_state, element_type, action, _data) do
    {:error, "Unsupported world update: #{element_type} #{action}"}
  end

  defp query_world_information(world_state, "all", _filter) do
    world_state |> Map.from_struct() |> Map.drop([:__meta__])
  end

  defp query_world_information(world_state, "location", _filter) do
    world_state.locations
  end

  defp query_world_information(world_state, "npc", _filter) do
    world_state.npcs
  end

  defp query_world_information(world_state, "event", _filter) do
    world_state.events
  end

  defp query_world_information(world_state, "quest", _filter) do
    world_state.quest_log
  end

  defp query_world_information(world_state, "story_flag", _filter) do
    world_state.story_flags
  end

  defp merge_game_states(game_state_updates, base_state) do
    # Take the most recent non-nil values for each field
    Enum.reduce(game_state_updates, base_state, fn update_state, acc ->
      %{
        world_state: update_state[:world_state] || acc.world_state,
        characters: update_state[:characters] || acc.characters,
        session: update_state[:session] || acc.session
      }
    end)
  end
end