defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def cache_size(cache_pid) do
    GenServer.call(cache_pid, {:cache_size})
  end

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, state) do
    case Map.fetch(state, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, state}
      :error ->
        {:ok, todo_server} = Todo.Server.start(todo_list_name)
        {:reply, todo_server, Map.put(state, todo_list_name, todo_server)}
    end
  end

  @impl GenServer
  def handle_call({:cache_size}, _, state) do
    {:reply, map_size(state), state}
  end

  def handle_call(request, _, state) do
    {:reply, request, state}
  end
end
