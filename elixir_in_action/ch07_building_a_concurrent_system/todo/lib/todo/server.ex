defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  @impl GenServer
  def init(name) do
    send(self(), {:init, name})
    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:init, name}, _) do
    db = Todo.Database.get(name)
    {:noreply, {name, db || Todo.List.new()}}
  end

  @spec add_entry(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add, entry})
  end

  @impl GenServer
  def handle_cast({:add, entry}, {name, cur_list}) do
    new_list = Todo.List.add_entry(cur_list, entry)
    Todo.Database.store(name, new_list) # can cause backpressure issues
    {:noreply, {name, new_list}}
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, cur_list}) do
    entries = Map.get(cur_list, date, [])
    {:reply, entries, {name, cur_list}}
  end

  def keys(todo_server) do
    GenServer.call(todo_server, {:keys})
  end

  @impl GenServer
  def handle_call({:keys}, _, {name, cur_list}) do
    keys = Map.keys(cur_list)
   {:reply, keys, {name, cur_list}}
  end
end

# You should generally be careful about possibly long-running init/1 callbacks.
# Recall that GenServer.start returns only after the process has been initialized.
# Consequently, a long-running init/1 function will cause the creator process to block.
# One way to offset this is by sending the created process a message by the created process
# to initialise itself concurrently without blocking the creator process. This will work
# in most of the cases, but if the process is registered under a local name
# known to other processes (which can send a message to process mailbox before the process
# itself can) - we need to defer registering the process until initialization is done.
# This will make the initialization happen before any other message is handled.

# GenServer.call has a default timeout of 5 seconds

# Reasons to use server process:
# 1. Code must manage long living state
# 2. Code handles resources which can and should be reused like TCP connection,
# database connection, file handle, pipe to an OS process.
# 3. Critical section of the code must be synchronized - only one process may run

# Way to handle issues with process is - to not use process.
# If we remove the process for Database and make it a module, it will eliminate the
# issue of backpressure bottleneck. And it mostly checks for all the above points -
# the issue which can happen is: a million connected clients can fire million concurrent
# request to write to the disk.
