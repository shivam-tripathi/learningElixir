defmodule Todo.Database do
  use GenServer

  @db_loc "./persist/persist"
  @num_workers 3

  @spec start :: :ignore | {:error, any} | {:ok, pid}
  def start do
    workers = Enum.map(1..@num_workers, fn id ->
      {:ok, pid} = Todo.DatabaseWorker.start(id, "#{@db_loc}_#{id}")
      pid
    end)
    GenServer.start(__MODULE__, [workers: workers], name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  def choose_worker(key, workers) do
    idx = :erlang.phash2(key, @num_workers) - 1
    Enum.at(workers, idx)
  end

  @spec store(any, any) :: :ok
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    Todo.DatabaseWorker.store(choose_worker(key, state[:workers]), key, data)
    {:noreply, state}
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def handle_call({:get, key}, caller, state) do
    spawn(fn ->
      data = Todo.DatabaseWorker.get(choose_worker(key, state[:workers]), key)
      GenServer.reply(caller, data)
    end)
    {:noreply, state}
  end
end
