"""
Generators and Filters
"""

# Comprehensions are syntactic sugar for such constructs: they group
# those common tasks into the for special form.
a = for n <- [1, 2, 3, 4, 5], do: n * n
IO.inspect(a)

# n <- [1, 2, 3, 4] is the generator.
a = for n <- 1..10, do: n * 2
IO.inspect(a)

# Generators also support pattern matching
vals = [good: 1, good: 3, good: 5, bad: 7, good: 9]
a = for {:good, val} <- vals, do: val * 3
IO.inspect(a)

# filters can be used to select some particular elements
# Comprehensions discard all elements for which the filter expression returns
# false or nil; all other values are selected.
a = for n <- [1, 2, 3, 4, 5, 6], rem(n, 2) != 1, do: Kernel.trunc(n / 2)
IO.inspect(a)

# flatten nested list using multiple generators
a = for i <- [[1, 2, 3], [4, 5, 6], [7, 8, 9]], j <- i, do: j
IO.inspect(a)

# Cartesian product
a = for i <- [:a, :b, :c, :d], j <- [1, 2, 3], do: [i, j]
IO.inspect(a)

# keep in mind that variable assignments inside the comprehension, be it in generators,
# filters or inside the block, are not reflected outside of the comprehension.

"""
Bitstring generators
"""

# Bitstring generators are also supported and are very useful when you need to comprehend over
# bitstring streams

pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
a = for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
IO.inspect(a)
# [{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]

# str to list
str = "hello, world"
a = for <<i <- str>>, do: [i]
IO.inspect(a)

# A bitstring generator can be mixed with “regular” enumerable generators, and supports filters as well.

"""
:into operator
"""

# all the comprehensions returned lists as their result. However, the result of a comprehension can
# be inserted into different data structures by passing the :into option to the comprehension.

# remove all spaces
a = for <<c <- " a b c d e  f  g h i j k ">>, c != ?\s, into: "", do: <<c>>
IO.inspect(a)

# :into accepts any structure that implements the Collectable protocol.
# Sets, maps, and other dictionaries can also be given to the :into option

a = for {k, v} <- %{1 => 2, 2 => 3, 3 => 4, 4 => 5}, into: %{}, do: {k, v * 2 + 1}
IO.inspect(a)

# Streams with into

stream = IO.stream(:stdio, :line)

for line <- stream, into: stream do
  String.upcase(line)
end
