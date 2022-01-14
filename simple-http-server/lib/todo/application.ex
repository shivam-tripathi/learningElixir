defmodule Todo.Application do
  require Logger
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Todo.Router, options: [port: 3000]},
      {Todo.Server, [name: Todo.Server]}
    ]

    Logger.info("Starting application on port 3000.")
    opts = [strategy: :one_for_one, name: Todo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
