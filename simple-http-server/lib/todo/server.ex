defmodule Todo.Server do
  use GenServer

  def start_link(opts) do
    IO.inspect(func: "Start_link", opts: opts)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.inspect("init")
    {:ok, %{}}
  end

  def list() do
    GenServer.call(__MODULE__, {:list})
  end

  def add(todo) do
    GenServer.call(__MODULE__, {:add, todo})
  end

  def remove(id) do
    GenServer.call(__MODULE__, {:remove, id})
  end

  def toggle(id) do
    GenServer.call(__MODULE__, {:toggle, id})
  end

  def handle_call({:list}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add, todo}, _from, state) do
    task = %{name: todo, done: false}
    state = Map.put(state, generate_id(), task)
    {:reply, state, state}
  end

  def handle_call({:toggle, id}, _from, state) do
    task = Map.get(state, id)
    done = Map.get(task, :done)
    updated_task = Map.put(task, :done, !done)
    state = Map.put(state, id, updated_task)
    {:reply, state, state}
  end

  def handle_call({:remove, id}, _from, state) do
    state = Map.delete(state, id)
    {:reply, state, state}
  end

  defp generate_id() do
    :crypto.strong_rand_bytes(64)
    |> Base.url_encode64()
    |> binary_part(0, 64)
  end
end
