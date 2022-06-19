Code.load_file("todo_server.exs", ".")

todo_server = TodoServer.start()

todo_server
|> TodoServer.add_entry(%{date: ~D[2022-05-01], title: "office"})
|> TodoServer.add_entry(%{date: ~D[2022-05-01], title: "drink water"})
|> TodoServer.add_entry(%{date: ~D[2022-05-01], title: "study"})
|> TodoServer.add_entry(%{date: ~D[2022-05-01], title: "exercise"})
|> TodoServer.add_entry(%{date: ~D[2022-06-01], title: "vacation"})

IO.inspect(TodoServer.entries(todo_server, ~D[2022-05-01]))
IO.inspect(TodoServer.entries(todo_server, ~D[2022-06-01]))
