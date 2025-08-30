defmodule AgenticDm.LlmClient do
  @moduledoc """
  Client for interacting with OpenRouter API for LLM requests.
  Handles context management, token counting, and tool integration.
  """
  
  require Logger
  
  defstruct [
    :api_key,
    :base_url,
    :model,
    :temperature,
    :max_tokens,
    :timeout
  ]

  @default_base_url "https://openrouter.ai/api/v1"
  @default_model "anthropic/claude-3.5-sonnet"
  @default_temperature 0.7
  @default_max_tokens 4000
  @default_timeout 30_000

  def new(opts \\ []) do
    %__MODULE__{
      api_key: opts[:api_key] || System.get_env("OPENROUTER_API_KEY"),
      base_url: opts[:base_url] || System.get_env("OPENROUTER_BASE_URL") || @default_base_url,
      model: opts[:model] || System.get_env("DEFAULT_MODEL") || @default_model,
      temperature: opts[:temperature] || @default_temperature,
      max_tokens: opts[:max_tokens] || @default_max_tokens,
      timeout: opts[:timeout] || @default_timeout
    }
  end

  @doc """
  Generate a response from the LLM given a context structure.
  """
  def generate_response(client, context) do
    Logger.info("Generating LLM response with model: #{client.model}")
    
    with {:ok, messages} <- build_messages(context),
         {:ok, request_body} <- build_request(client, messages, context.available_tools || []),
         {:ok, response} <- make_api_request(client, request_body),
         {:ok, parsed_response} <- parse_response(response) do
      {:ok, parsed_response}
    else
      error -> 
        Logger.error("LLM request failed: #{inspect(error)}")
        error
    end
  end

  @doc """
  Estimate token count for a given text (approximate).
  """
  def estimate_token_count(text) when is_binary(text) do
    # Rough estimation: ~4 characters per token for English text
    String.length(text) |> div(4) |> max(1)
  end

  @doc """
  Summarize conversation history to fit within token limits.
  """
  def summarize_history(client, messages, max_tokens \\ 8000) do
    total_tokens = estimate_messages_tokens(messages)
    
    if total_tokens <= max_tokens do
      {:ok, messages}
    else
      # Keep the most recent messages and summarize older ones
      {recent, older} = split_messages_by_tokens(messages, max_tokens * 0.6)
      
      case summarize_messages(client, older) do
        {:ok, summary} ->
          summary_message = %{
            role: "system",
            content: "Previous session summary: #{summary}",
            timestamp: DateTime.utc_now()
          }
          {:ok, [summary_message | recent]}
        error -> error
      end
    end
  end

  # Private Functions

  defp build_messages(context) do
    messages = []
    
    # Add system prompt
    messages = if context[:system_prompt] do
      [%{role: "system", content: context.system_prompt} | messages]
    else
      messages
    end
    
    # Add lorebook context if present
    messages = if context[:lorebook_context] do
      lorebook_msg = %{
        role: "system", 
        content: "Relevant lore:\n\n#{context.lorebook_context}"
      }
      [lorebook_msg | messages]
    else
      messages
    end
    
    # Add conversation history
    history_messages = Enum.map(context[:conversation_history] || [], fn msg ->
      %{
        role: msg[:role] || "user",
        content: msg[:content] || ""
      }
    end)
    
    messages = messages ++ history_messages
    
    # Add current user message
    messages = if context[:user_message] do
      [%{role: "user", content: context.user_message} | messages]
    else
      messages
    end
    
    {:ok, Enum.reverse(messages)}
  end

  defp build_request(client, messages, tools) do
    request_body = %{
      model: client.model,
      messages: messages,
      temperature: client.temperature,
      max_tokens: client.max_tokens
    }
    
    # Add tools if provided
    request_body = if Enum.any?(tools) do
      Map.put(request_body, :tools, format_tools(tools))
    else
      request_body
    end
    
    {:ok, request_body}
  end

  defp format_tools(tools) do
    Enum.map(tools, fn tool ->
      %{
        type: "function",
        function: %{
          name: tool.name,
          description: tool.description,
          parameters: tool.parameters || %{}
        }
      }
    end)
  end

  defp make_api_request(client, request_body) do
    headers = [
      {"Authorization", "Bearer #{client.api_key}"},
      {"Content-Type", "application/json"},
      {"HTTP-Referer", "https://github.com/agentic-dm"},
      {"X-Title", "Agentic D&D DM"}
    ]
    
    url = "#{client.base_url}/chat/completions"
    body = Jason.encode!(request_body)
    
    case HTTPoison.post(url, body, headers, timeout: client.timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, parsed} -> {:ok, parsed}
          error -> {:error, {:json_decode_error, error}}
        end
      
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("API request failed with status #{status_code}: #{body}")
        {:error, {:api_error, status_code, body}}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, {:http_error, reason}}
    end
  end

  defp parse_response(api_response) do
    case api_response do
      %{"choices" => [choice | _]} ->
        message = choice["message"] || %{}
        
        response = %{
          content: message["content"] || "",
          role: message["role"] || "assistant",
          tool_calls: parse_tool_calls(message["tool_calls"]),
          usage: parse_usage(api_response["usage"]),
          model: api_response["model"]
        }
        
        {:ok, response}
      
      _ ->
        {:error, {:invalid_response, api_response}}
    end
  end

  defp parse_tool_calls(nil), do: []
  defp parse_tool_calls(tool_calls) when is_list(tool_calls) do
    Enum.map(tool_calls, fn tool_call ->
      %{
        id: tool_call["id"],
        type: tool_call["type"],
        function: %{
          name: tool_call["function"]["name"],
          arguments: Jason.decode!(tool_call["function"]["arguments"] || "{}")
        }
      }
    end)
  end

  defp parse_usage(nil), do: %{prompt_tokens: 0, completion_tokens: 0, total_tokens: 0}
  defp parse_usage(usage) do
    %{
      prompt_tokens: usage["prompt_tokens"] || 0,
      completion_tokens: usage["completion_tokens"] || 0,
      total_tokens: usage["total_tokens"] || 0
    }
  end

  defp estimate_messages_tokens(messages) do
    messages
    |> Enum.map(fn msg -> estimate_token_count(msg[:content] || "") end)
    |> Enum.sum()
  end

  defp split_messages_by_tokens(messages, target_tokens) do
    {recent, older, _current_tokens} = 
      Enum.reduce(messages, {[], [], 0}, fn msg, {recent, older, tokens} ->
        msg_tokens = estimate_token_count(msg[:content] || "")
        
        if tokens + msg_tokens <= target_tokens do
          {[msg | recent], older, tokens + msg_tokens}
        else
          {recent, [msg | older], tokens}
        end
      end)
    
    {Enum.reverse(recent), Enum.reverse(older)}
  end

  defp summarize_messages(client, messages) do
    if Enum.empty?(messages) do
      {:ok, "No previous messages to summarize."}
    else
      content = messages
        |> Enum.map(fn msg -> 
          "#{msg[:role] || "unknown"}: #{msg[:content] || ""}" 
        end)
        |> Enum.join("\n\n")
      
      summary_request = %{
        system_prompt: """
        Please provide a concise summary of the following D&D session messages. 
        Focus on key events, character actions, story progression, and important decisions.
        Keep it under 500 words.
        """,
        user_message: content
      }
      
      case generate_response(client, summary_request) do
        {:ok, response} -> {:ok, response.content}
        error -> error
      end
    end
  end
end