defmodule KeyValueStore do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, %{}, name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def terminate() do
    GenServer.call(__MODULE__, {:terminate})
  end

  @impl GenServer
  def init(initial_arg \\ %{}) do
    {:ok, initial_arg}
    # Can also return :ignore or {:stop, reason}
  end

  # handle_* can return {:stop, reason, state} to stop the server
  @impl
  def handle_cast({:terminate}, state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end

# KeyValueStore.__info__(:functions)
# [child_spec: 1, code_change: 3, handle_call: 3, handle_cast: 2, handle_info: 2, init: 1, terminate: 2]
