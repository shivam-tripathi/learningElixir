# In Elixir, all code runs inside processes. Processes are isolated from each
# other, run concurrent to one another and communicate via message passing.

pid = spawn(fn x -> 2 * x end)
IO.inspect(self())
IO.inspect(pid)
IO.puts(Process.alive?(pid))

# When a message is sent to a process, the message is stored in the process mailbox
send(self(), {:hello, :world})
send(self(), {"olaf", "bogota"})

# The receive/1 block goes through the current process mailbox searching for a
# message that matches any of the given patterns

receive do
  {:hello, value} -> IO.puts("hello, #{value}")
  {key, value} -> IO.puts("No match 2 #{key} #{value}")
end

receive do
  {"olaf", value} -> IO.puts("manila to #{value}")
  {key, value} -> IO.puts("No match 1 #{key} #{value}")
end

Process.send_after(self(), {:key, :value}, 1_500)

# If there is no message in the mailbox matching any of the patterns, the current
# process will wait until a matching message arrives. A timeout can also be specified:
receive do
  {key, value} ->
    IO.inspect({"matched", key, value})

  _ ->
    IO.puts("No match 3")
after
  2_000 ->
    IO.puts("Timeout")
end

parent = self()
pid = spawn(fn -> send(parent, {:child, self()}) end)

receive do
  {:child, value} ->
    IO.inspect([parent, value])
end

# Linked process, when raises error - propagate error to linking process
# spawn_link(fn -> raise "oops" end)

# Tasks build on top of the spawn functions to provide better error reports and introspection
# Task.start(fn -> raise "oops" end)

# Instead of spawn/1 and spawn_link/1, we use Task.start/1 and Task.start_link/1 which
# return {:ok, pid} rather than just the PID. This is what enables tasks to be used in
# supervision trees. Task provides convenience functions, like Task.async/1 and Task.await/1, and
# functionality to ease distribution.

# State
# We can write processes that loop infinitely, maintain state, and send and receive messages.
defmodule KV do
  def start_link() do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send(caller, Map.get(map, key))
        loop(map)

      {:set, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end

{:ok, pid} = KV.start_link()

Process.register(pid, :kv)

send(:kv, {:set, :hello, 23})
send(:kv, {:get, :hello, self()})

receive do
  val ->
    IO.inspect("received = #{val}")
end

# Elixir provides agents, which are simple abstractions around state:
{:ok, pid} = Agent.start_link(fn -> %{} end, name: :kv2)
Agent.update(:kv2, fn map -> Map.put(map, :hello, :world) end)
IO.puts("Agent returns: #{Agent.get(:kv2, fn map -> Map.get(map, :hello) end)}")
