defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    ram_pid = Todo.Cache.server_process(cache, "ram_list")
    assert ram_pid != Todo.Cache.server_process(cache, "shyam_list")
    assert ram_pid == Todo.Cache.server_process(cache, "ram_list")
  end

  test "todo_operations" do
    {:ok, cache} = Todo.Cache.start()
    ram = Todo.Cache.server_process(cache, "ram")
    Todo.Server.add_entry(ram, %{date: ~D[2022-01-01], title: "vihaar"})
    Todo.Server.add_entry(ram, %{date: ~D[2022-01-01], title: "darbar"})
    entries = Todo.Server.entries(ram, ~D[2022-01-01])
    assert ["darbar", "vihaar"] == entries
  end
end
