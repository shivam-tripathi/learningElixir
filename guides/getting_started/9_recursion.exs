defmodule Recursion do
  @spec print_multiple(str :: String.t(), times :: integer) :: :ok
  def print_multiple(str, times) when times > 0 do
    IO.puts(str)
    print_multiple(str, times - 1)
  end

  @spec print_multiple(str :: String.t(), times :: integer) :: :ok
  def print_multiple(_str, 0) do
    :ok
  end
end

Recursion.print_multiple("hello", 3)

defmodule MapReduce do
  @spec sum_list(lis :: [integer], sum :: integer) :: integer
  def sum_list([head | tail], sum) do
    sum_list(tail, sum + head)
  end

  def sum_list([], sum) do
    sum
  end

  @spec double_each(lis :: [integer]) :: [integer]
  def double_each([head | tail]) do
    [2 * head | double_each(tail)]
  end

  @spec double_each(lis :: [integer]) :: [integer]
  def double_each([]) do
    []
  end
end

IO.puts(MapReduce.sum_list([1, 2, 3, 4, 5, 6], 0))
IO.inspect(MapReduce.double_each([1, 2, 3, 4, 5, 6]))

defmodule EnumDemoInitial do
  def sum_list(lis) do
    # equal to fn (a, b) -> a + b end
    Enum.reduce(lis, 0, &+/2)
  end

  def double_each(lis) do
    Enum.map(lis, &(&1 * 2))
  end
end

IO.puts(EnumDemoInitial.sum_list([1, 2, 3, 4, 5, 6]))
IO.inspect(EnumDemoInitial.double_each([1, 2, 3, 4, 5, 6]))
