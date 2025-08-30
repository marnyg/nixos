defmodule AgenticDm.Main do
  @moduledoc """
  Main entry point for the Agentic D&D DM CLI application.
  """
  
  def main(args) do
    # Ensure the application is started
    Application.ensure_all_started(:agentic_dm)
    
    # Run the CLI
    AgenticDm.CLI.main(args)
  end
end