defmodule EnumDemo do
  # All the functions in the Enum module are eager. Many functions expect an enumerable and
  # return a list back:
  # This means that when performing multiple operations with Enum, each operation
  # is going to generate an intermediate list until we reach the result.

  def map_list(lis) do
    Enum.map(lis, fn x -> x * 2 end)
  end

  def map_dict(dict) do
    Enum.map(dict, fn {k, v} -> [k, v] end)
  end

  def ranges() do
    Enum.reduce(1..10, 0, &+/2)
  end

  def odd_filter(lis) do
    odd? = &(rem(&1, 2) != 0)
    Enum.filter(lis, odd?)
  end

  def pipe_demo() do
    1..100_000 |> Enum.map(&(&1 * 3)) |> Enum.filter(&(rem(&1, 2) != 0)) |> Enum.sum()
  end

  # All the functions in Streams are lazy. Many functions in the Stream module accept any
  # enumerable as an argument and return a stream as a result.
  # Streams are lazy, composable enumerables.
  # Instead of generating intermediate lists, streams build a series of computations
  # that are invoked only when we pass the underlying stream to the Enum module. Streams
  # are useful when working with large, possibly infinite, collections.

  def stream_demo() do
    1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(&(rem(&1, 2) != 0)) |> Enum.sum()
  end

  def stream_create_demo() do
    Stream.cycle(1..5) |> Enum.take(9)
  end

  # Stream.unfold/2 can be used to generate values from a given initial value:
  def stream_unfold() do
    inp = "hello, world!"
    stream = Stream.unfold(inp, &String.next_codepoint/1)
    {Enum.take(stream, 2), Enum.take(stream, 2)}
  end

  # Another interesting function is Stream.resource/3 which can be used to wrap around
  # resources, guaranteeing they are opened right before enumeration and closed afterwards,
  # even in the case of failures.
  def stream_resouce() do
    stream = File.stream!("./simple.exs")
    Enum.take(stream, 3)
  end

  def random_numbers_in_range(first, last) do
    Stream.repeatedly(&:rand.uniform/0)
    |> Stream.map(&(&1 * (last - first) + first))
    |> Stream.map(&Float.ceil/1)
    |> Stream.map(&Kernel.trunc/1)
    |> Enum.take(100)
  end
end

IO.inspect(EnumDemo.map_list([1, 2, 3, 4]))
IO.inspect(EnumDemo.map_dict(%{56 => 109, k: 23, v: 45}))
IO.inspect(EnumDemo.ranges())
IO.inspect(EnumDemo.odd_filter([1, 2, 3, 4, 5, 6, 7, 8]))
IO.puts(EnumDemo.pipe_demo())
IO.puts(EnumDemo.stream_demo())
IO.inspect(EnumDemo.stream_create_demo())
IO.inspect(EnumDemo.stream_unfold())
IO.inspect(EnumDemo.stream_resouce())
IO.inspect(EnumDemo.random_numbers_in_range(15, 75))
