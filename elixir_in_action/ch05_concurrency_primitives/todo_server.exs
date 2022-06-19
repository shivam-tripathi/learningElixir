defmodule TodoList do
  def new(), do: %{}

  def add_entry(todo_list, new_entry) do
    %{title: title, date: date} = new_entry
    Map.update(todo_list, date, [title], fn titles -> [title | titles] end)
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end

defmodule TodoServer do
  def start() do
    todo_list = TodoList.new()
    spawn(fn -> loop(todo_list) end)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message ->
          process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    entries = TodoList.entries(todo_list, date)
    send(caller, {:entries, entries})
    todo_list
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
    todo_server
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:entries, value} -> value
    after
      5000 -> {:error, :timeout}
    end
  end
end
