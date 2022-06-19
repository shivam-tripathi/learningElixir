Code.load_file("database.exs", ".")

# server = DatabaseServer.start()
# IO.inspect(Enum.map(1..10, &DatabaseServer.run_query_async(server, "query #{&1}")))
# IO.inspect(Enum.map(1..10, fn _ -> DatabaseServer.get_result() end))

servers =
  Enum.reduce(1..10, %{}, fn id, acc ->
    Map.merge(%{id => DatabaseServer.start()}, acc)
  end)

IO.inspect(["number of servers ::", map_size(servers)])

Enum.each(1..10, fn id ->
  server = Map.get(servers, id)
  DatabaseServer.run_query_async(server, "query #{id}")
end)

IO.inspect(Enum.map(1..10, fn _ -> DatabaseServer.get_result() end))
