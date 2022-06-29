Code.load_file("server_process.exs", ".")

server_pid = ServerProcess.start(KeyValueStore)
ServerProcess.call(server_pid, {:put, "name", "jerry"})
res = ServerProcess.call(server_pid, {:get, "name"})
Enum.map(1..10, fn k -> ServerProcess.call(server_pid, {:put, k, 2 * k}) end)
values = Enum.map(1..10, fn k -> ServerProcess.call(server_pid, {:get, k}) end)
IO.inspect(values)
