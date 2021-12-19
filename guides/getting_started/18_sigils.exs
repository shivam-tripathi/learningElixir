# Sigils are one of the mechanisms provided by the language for working with textual
# representations

# regex
regex = ~r/^Part\s+\d+$/
IO.puts("Part 1d" =~ regex)
IO.puts("Part 18" =~ regex)

"""
Other forms of regex sigils
~r/hello/
~r|hello|
~r"hello"
~r'hello'
~r(hello)
~r[hello]
~r{hello}
~r<hello>
"""

IO.puts(~s(Strings with "double quotes" easily 'created'))
IO.inspect(~c(Charlist with 'single quotes' easily "created"))
IO.inspect(~w(Word list automatically created))
IO.inspect(~w(Word List Can Have Atoms)a)
IO.inspect(~w(Word List Can Also Have CharLists)c)
IO.inspect(~s(Escape \x26 #{"inter" <> "polation"}))
IO.inspect(~S(Escape \x26 #{"inter" <> "polation"}))

# Heredocs - for example use with @doc
IO.puts(~S"""
The following escape codes can be used in strings and char lists:
\\ – single backslash
\a – bell/alert
\b – backspace
\d - delete
\e - escape
\f - form feed
\n – newline
\r – carriage return
\s – space
\t – tab
\v – vertical tab
\0 - null byte
\xDD - represents a single byte in hexadecimal (such as \x13)
\uDDDD and \u{D...} - represents a Unicode codepoint in hexadecimal (such as \u{1F600})
""")

# Date
date = ~D[2021-12-19]
IO.inspect([date.day, date.month, date.year])

# Time
time = ~T[10:58:09.013]

IO.inspect(
  hour: time.hour,
  minute: time.minute,
  second: time.second,
  microsecond: time.microsecond
)

# Naive Date Time
naivedatetime = ~N[2021-12-19 10:58:09.013]

IO.inspect(
  day: naivedatetime.hour,
  month: naivedatetime.month,
  year: naivedatetime.year,
  hour: naivedatetime.hour,
  minute: naivedatetime.minute,
  second: naivedatetime.second,
  microsecond: naivedatetime.microsecond
)

# UTC datetime
utc = ~U[2021-12-19T10:58:09.013Z]

IO.inspect(
  day: utc.hour,
  month: utc.month,
  year: utc.year,
  hour: utc.hour,
  minute: utc.minute,
  second: utc.second,
  microsecond: utc.microsecond
)

# Custom sigils
defmodule CustomSigils do
  def sigil_i(string, []), do: String.to_integer(string)
  def sigil_i(string, [?n]), do: -String.to_integer(string)
end

# This can be imported and used like:
# IO.puts(i(14))
# IO.puts(i(123)n)

# Sigils can also be used to do compile-time work with the help of macros.
# For example, regular expressions in Elixir are compiled into an efficient representation
# during compilation of the source code, therefore skipping this step at runtime.
