# Protocols are a mechanism to achieve polymorphism in Elixir when you want behavior to
# vary depending on the data type. One way to do this is via pattern matching and guard clauses.
# Other way is to protocols. We define the protocol using defprotocol - its functions and specs
# may look similar to interfaces or abstract base classes in other languages.

# With protocols, however, we are no longer stuck having to continuously modify the same module to
# support more and more data types. For example, we could get the defimpl calls above and spread
# them over multiple files and Elixir will dispatch the execution to the appropriate implementation
# based on the data type. Functions defined in a protocol may have more than one input, but the
# dispatching will always be based on the data type of the first input.

# It’s possible to implement protocols for all Elixir data types:
#     Atom
#     BitString
#     Float
#     Function
#     Integer
#     List
#     Map
#     PID
#     Port
#     Reference
#     Tuple

defmodule Type do
  def type(value) when is_atom(value), do: "atom"
  def type(value) when is_binary(value), do: "string"
end

IO.puts(Type.type(:atom))
IO.puts(Type.type("STR"))

# dispatching on a protocol is available to any data type that has implemented the protocol
# and a protocol can be implemented by anyone, at any time.
defprotocol Utility do
  @spec type(t) :: String.t()
  def type(t)
end

defimpl Utility, for: BitString do
  def type(_t), do: "string"
end

defimpl Utility, for: Integer do
  def type(_t), do: "integer"
end

defimpl Utility, for: Atom do
  def type(_t), do: "atom"
end

IO.puts(Utility.type(23))
IO.puts(Utility.type("hola"))
IO.puts(Utility.type(:atom))

# Custom protocol
defprotocol Size do
  @doc "Calculates the size (and not the length!) of a data structure"
  # @spec size(data) :: integer
  def size(data)
end

defimpl Size, for: BitString do
  def size(str), do: byte_size(str)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

defimpl Size, for: Map do
  def size(map), do: Kernel.map_size(map)
end

IO.puts(Size.size("hola"))
IO.puts(Size.size({1, 2, 3, 4}))
IO.puts(Size.size(%{one: 1, two: 2, three: 3, four: 4}))

"""
Protocols and structs
"""

# although structs are maps, they do not share protocol implementations with maps. For example,
# MapSets (sets based on maps) are implemented as structs.
IO.puts(Size.size(%{}))
# :err
# IO.puts(Size.size(MapSet.new()))

# Instead of sharing protocol implementation with maps, structs require their own protocol
# implementation.
defimpl Size, for: MapSet do
  def size(set), do: MapSet.size(set)
end

IO.puts(Size.size(MapSet.put(MapSet.new(), 23)))

defmodule User do
  defstruct name: "John Doe", age: 23
end

defimpl String.Chars, for: User do
  def to_string(user), do: "Name: #{user.name} and Age: = #{user.age}"
end

# IO.puts(%User{})

# Manually implementing protocols for all types can quickly become repetitive and tedious.
# we can explicitly derive the protocol implementation for our types or automatically implement
# the protocol for all types.

# Elixir allows us to derive a protocol implementation based on the Any implementation.
# Poor derivation is below, but this works only if we tell our structs to explicitly to derive the
# Size protocol
defimpl Size, for: Any do
  def size(_), do: 0
end

defmodule UserOther do
  @derive [Size]
  defstruct name: "henlo", age: 34
end

# Another alternative to @derive is to explicitly tell the protocol to fallback to Any when an
# implementation cannot be found
defprotocol Size2 do
  @fallback_to_any true
  def size(obj)
end

# The implementation of Size for Any is not one that can apply to any data type.
# That’s one of the reasons why @fallback_to_any is an opt-in behaviour. More often than not
# we need to raise an exception
defimpl Size2, for: Any do
  def size(_), do: 0
end

"""
Built in protocols

Elixir ships with some built-in protocols. In previous chapters, we have discussed the Enum module
which provides many functions that work with any data structure that implements the Enumerable
protocol:
"""

IO.inspect(Enum.map([1, 2, 3], fn x -> x * 2 end))

IO.inspect(Enum.reduce(1..3, 0, fn x, acc -> x + acc end))

IO.inspect(to_string(:string_atom))

# Notice that string interpolation in Elixir calls the to_string function:
IO.inspect("age: #{25}")

# Tuples do not implement String.Chars
# error:
# IO.inspect("tuple: #{{1, 2, 3}}")

# When there is a need to “print” a more complex data structure, one can use the inspect function,
# based on the Inspect protocol:
IO.inspect({1, 2, 3})

# whenever the inspected value starts with #, it is representing a data structure in non-valid
# Elixir syntax. This means the inspect protocol is not reversible as information may be lost along
# the way
