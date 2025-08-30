defmodule AgenticDm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Database repository
      AgenticDm.Repo,
      
      # Registry for tracking active sessions
      {Registry, keys: :unique, name: AgenticDm.SessionRegistry},
      
      # Dynamic supervisor for DM agent processes
      {DynamicSupervisor, strategy: :one_for_one, name: AgenticDm.DmSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AgenticDm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
