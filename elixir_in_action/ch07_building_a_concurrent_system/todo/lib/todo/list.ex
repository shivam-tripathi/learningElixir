defmodule Todo.List do
  @spec new :: %{}
  def new(), do: %{}

  @spec add_entry(map, %{:date => Date, :title => String, optional(any) => any}) :: map
  def add_entry(todo_list, new_entry) do
    %{title: title, date: date} = new_entry
    Map.update(todo_list, date, [title], fn existing_value -> [title | existing_value] end)
  end

  @spec entries(map, Date) :: [String.t()]
  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end
