defmodule AgenticDm.LorebookManager do
  @moduledoc """
  Manages dynamic context injection from lorebook entries.
  Automatically selects and injects relevant lore based on conversation context.
  """
  
  require Logger
  alias AgenticDm.{GameState, LlmClient}
  alias AgenticDm.Schemas.LorebookEntry
  
  defstruct [
    :campaign_name,
    :max_context_tokens,
    :max_entries_per_injection,
    :keyword_cache,
    :last_cache_update
  ]
  
  @default_max_context_tokens 8000
  @default_max_entries 5
  
  def new(campaign_name, opts \\ []) do
    %__MODULE__{
      campaign_name: campaign_name,
      max_context_tokens: opts[:max_context_tokens] || @default_max_context_tokens,
      max_entries_per_injection: opts[:max_entries] || @default_max_entries,
      keyword_cache: %{},
      last_cache_update: nil
    }
  end
  
  @doc """
  Inject relevant lorebook context into the conversation context.
  """
  def inject_context(manager, base_context) do
    Logger.info("Injecting lorebook context for campaign: #{manager.campaign_name}")
    
    case get_relevant_entries(manager, base_context) do
      {:ok, []} ->
        Logger.info("No relevant lorebook entries found")
        {:ok, base_context}
      
      {:ok, entries} ->
        Logger.info("Found #{length(entries)} relevant lorebook entries")
        
        case build_lorebook_context(entries, manager.max_context_tokens) do
          {:ok, lorebook_text} ->
            enhanced_context = Map.put(base_context, :lorebook_context, lorebook_text)
            {:ok, enhanced_context}
          error -> error
        end
      
      error -> error
    end
  end
  
  @doc """
  Find lorebook entries relevant to the current conversation context.
  """
  def get_relevant_entries(manager, context) do
    # Extract keywords from recent conversation
    keywords = extract_keywords_from_context(context)
    
    if Enum.empty?(keywords) do
      {:ok, []}
    else
      # Get all entries for this campaign
      entries = GameState.list_lorebook_entries(manager.campaign_name)
      
      # Filter and rank entries by relevance
      relevant_entries = entries
        |> filter_triggerable_entries()
        |> calculate_relevance_scores(keywords, context)
        |> sort_by_relevance()
        |> Enum.take(manager.max_entries_per_injection)
      
      # Update trigger counts for selected entries
      updated_entries = Enum.map(relevant_entries, fn entry ->
        case LorebookEntry.can_trigger?(entry) do
          true -> 
            triggered = LorebookEntry.trigger_entry(entry)
            GameState.update_lorebook_entry(triggered)
            triggered
          false -> entry
        end
      end)
      
      {:ok, updated_entries}
    end
  end
  
  @doc """
  Reset session trigger counts for all entries in a campaign.
  """
  def reset_session_triggers(manager) do
    entries = GameState.list_lorebook_entries(manager.campaign_name)
    
    Enum.each(entries, fn entry ->
      reset_entry = LorebookEntry.reset_session_triggers(entry)
      GameState.update_lorebook_entry(reset_entry)
    end)
    
    :ok
  end
  
  @doc """
  Add a new lorebook entry dynamically during gameplay.
  """
  def add_dynamic_entry(manager, title, content, keywords, opts \\ []) do
    attrs = %{
      title: title,
      content: content,
      keywords: keywords,
      campaign_name: manager.campaign_name,
      priority: opts[:priority] || 1,
      category: opts[:category] || "dynamic",
      created_by: "dm_agent",
      auto_trigger: opts[:auto_trigger] != false,
      active: opts[:active] != false
    }
    |> Map.merge(Map.new(opts))
    
    case GameState.create_lorebook_entry(attrs) do
      {:ok, entry} ->
        Logger.info("Created dynamic lorebook entry: #{title}")
        {:ok, entry}
      error ->
        Logger.error("Failed to create lorebook entry: #{inspect(error)}")
        error
    end
  end
  
  @doc """
  Update the keyword cache for faster lookups.
  """
  def update_keyword_cache(manager) do
    entries = GameState.list_lorebook_entries(manager.campaign_name)
    
    keyword_cache = entries
      |> Enum.reduce(%{}, fn entry, acc ->
        Enum.reduce(entry.keywords, acc, fn keyword, keyword_acc ->
          normalized_keyword = String.downcase(String.trim(keyword))
          current_entries = Map.get(keyword_acc, normalized_keyword, [])
          Map.put(keyword_acc, normalized_keyword, [entry | current_entries])
        end)
      end)
    
    %{manager | 
      keyword_cache: keyword_cache, 
      last_cache_update: DateTime.utc_now()
    }
  end
  
  # Private Functions
  
  defp extract_keywords_from_context(context) do
    text_sources = []
    
    # Get text from user message
    text_sources = if context[:user_message] do
      [context.user_message | text_sources]
    else
      text_sources
    end
    
    # Get text from recent conversation history (last 5 messages)
    text_sources = if context[:conversation_history] do
      recent_messages = context.conversation_history
        |> Enum.take(-5)
        |> Enum.map(fn msg -> msg[:content] || "" end)
      
      recent_messages ++ text_sources
    else
      text_sources
    end
    
    # Extract meaningful keywords (simple implementation)
    text_sources
    |> Enum.join(" ")
    |> String.downcase()
    |> String.split(~r/\W+/)
    |> Enum.filter(fn word -> 
      String.length(word) > 3 and not is_common_word?(word)
    end)
    |> Enum.uniq()
  end
  
  defp is_common_word?(word) do
    common_words = ~w(
      the and or but not with for from this that they them their there
      where when what who why how said says will would could should might
      have has had been being was were are will would going come came
      very much more most some many any all each every both either neither
      about above after again against among around before below between
      during into over through under until upon within without
    )
    
    word in common_words
  end
  
  defp filter_triggerable_entries(entries) do
    Enum.filter(entries, &LorebookEntry.can_trigger?/1)
  end
  
  defp calculate_relevance_scores(entries, keywords, context) do
    # Get recent conversation text for context matching
    recent_text = get_recent_conversation_text(context, 1000)
    
    Enum.map(entries, fn entry ->
      score = LorebookEntry.calculate_relevance_score(entry, context[:conversation_history] || [])
      
      # Additional scoring based on keyword matches
      keyword_score = calculate_keyword_match_score(entry, keywords)
      
      # Boost score if content is mentioned in recent conversation
      content_score = calculate_content_relevance_score(entry, recent_text)
      
      final_score = score + keyword_score + content_score
      
      {entry, final_score}
    end)
  end
  
  defp calculate_keyword_match_score(entry, keywords) do
    matches = Enum.count(entry.keywords, fn entry_keyword ->
      normalized_entry_keyword = String.downcase(entry_keyword)
      
      Enum.any?(keywords, fn search_keyword ->
        String.contains?(normalized_entry_keyword, search_keyword) or
        String.contains?(search_keyword, normalized_entry_keyword)
      end)
    end)
    
    matches * 3  # 3 points per keyword match
  end
  
  defp calculate_content_relevance_score(entry, recent_text) do
    # Check if any of the entry's keywords appear in recent conversation
    entry.keywords
    |> Enum.count(fn keyword ->
      String.contains?(String.downcase(recent_text), String.downcase(keyword))
    end)
    |> Kernel.*(2)  # 2 points per keyword found in recent text
  end
  
  defp get_recent_conversation_text(context, max_chars) do
    context[:conversation_history]
    |> List.wrap()
    |> Enum.take(-3)  # Last 3 messages
    |> Enum.map(fn msg -> msg[:content] || "" end)
    |> Enum.join(" ")
    |> String.slice(0, max_chars)
  end
  
  defp sort_by_relevance(scored_entries) do
    scored_entries
    |> Enum.sort_by(fn {_entry, score} -> score end, :desc)
    |> Enum.map(fn {entry, _score} -> entry end)
  end
  
  defp build_lorebook_context(entries, max_tokens) do
    context_parts = []
    current_tokens = 0
    
    {final_parts, _} = Enum.reduce_while(entries, {context_parts, current_tokens}, 
      fn entry, {parts, tokens} ->
        entry_text = format_entry_for_context(entry)
        entry_tokens = LlmClient.estimate_token_count(entry_text)
        
        if tokens + entry_tokens <= max_tokens do
          {:cont, {[entry_text | parts], tokens + entry_tokens}}
        else
          {:halt, {parts, tokens}}
        end
      end
    )
    
    if Enum.empty?(final_parts) do
      {:ok, ""}
    else
      context_text = final_parts
        |> Enum.reverse()
        |> Enum.join("\n\n")
      
      {:ok, context_text}
    end
  end
  
  defp format_entry_for_context(entry) do
    header = if entry.category do
      "[#{entry.category}] #{entry.title}"
    else
      entry.title
    end
    
    "#{header}:\n#{entry.content}"
  end
end