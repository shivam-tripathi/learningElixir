# The concurrency model relies on Actors, a contained process that communicates with other processes
# through message passing.

# Processes in the Erlang VM are lightweight and run across all CPUs. While they may seem like
# native threads, they’re simpler and it’s not uncommon to have thousands of concurrent processes
# in an Elixir application.

defmodule Example do
  def add(a, b) do
    IO.puts(a + b)
  end
end

# Sync
Example.add(23, 43)

# Async
pid = spawn(Example, :add, [23, 43])
IO.inspect(pid)

defmodule MessagePassing do
  @doc """

  Message passing

  To communicate, processes rely on message passing. There are two main components to this: send/2 and
  receive. The send/2 function allows us to send messages to PIDs. To listen we use receive to match
  messages. If no match is found the execution continues uninterrupted.

  listen/0 function is recursive, this allows our process to handle multiple messages. Without
  recursion our process would exit after handling the first message.
  """
  def listen do
    receive do
      {:ok, name} ->
        IO.puts("hello, #{name}")

      name ->
        IO.puts("nothing matches for: #{name}")
    end

    listen()
  end
end

pid = spawn(MessagePassing, :listen, [])

# Will print
send(pid, {:ok, "world"})
# Will ignore as there is no matching clause
send(pid, "omega")

defmodule ProcessLinking do
  @doc """
  spawn doesn't help us to know when the spawned process has crashed, we use spawn_link for that

  Two linked processes will receive exit notifications from one another:
  """
  def explode, do: exit(:kaboom)

  def run do
    # Sometimes (as in this case), we do not want the main process to crash because linked process
    # has crashed, so we trap_exit
    Process.flag(:trap_exit, true)
    spawn_link(ProcessLinking, :explode, [])
    # Record trapped exit to console
    receive do
      {:EXIT, _from_pid, reason} ->
        IO.inspect("Exit trapped #{reason}")
    end
  end
end

ProcessLinking.run()

defmodule ProcessMonitoring do
  @doc """
    If we don't want to link two processes, but still be informed if they have exited - we use
    spawn_monitor.
    When we monitor a process we get a message if the process crashes without our current process
    crashing or needing to explicitly trap exits.
  """

  def explode, do: exit(:explode)

  def run do
    spawn_monitor(ProcessMonitoring, :explode, [])

    receive do
      {:DOWN, _ref, :process, _from_pid, reason} ->
        IO.inspect("monitored process down because: #{reason}")
    end
  end
end

ProcessMonitoring.run()

defmodule Agents do
  def start() do
    Agent.start_link(fn -> %{} end, name: :agent_map)
  end

  def add(key, value) do
    Agent.update(:agent_map, fn map -> Map.put(map, key, value) end)
  end

  def get() do
    Agent.get(:agent_map, & &1)
  end
end

Agents.start()
Agents.add("hello", "world")
Agents.add("key", [1, 2, 3])
IO.inspect(Agents.get())

defmodule Tasks do
  @doc """
  Tasks provide a way to execute a function in the background and retrieve its return value later.
  They can be particularly useful when handling expensive operations without blocking the
  application execution.
  """
  def double(x) do
    :timer.sleep(2000)
    x * 2
  end
end

tasks = [
  Task.async(Tasks, :double, [2]),
  Task.async(Tasks, :double, [23]),
  Task.async(Tasks, :double, [34])
]

res = Task.await_many(tasks)
IO.inspect(res)
