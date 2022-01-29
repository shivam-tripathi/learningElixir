# It is more commong to return {:error, reason} tuple (similar to golang), elixir does have
# exceptions. The convention in Elixir is to create a function (example/1) which returns
# {:ok, result} and {:error, reason} and a separate function (example!/1) that returns the
# unwrapped result or raises an error.

# Conventions
# + For errors that are part of the regular operation of a function (e.g. a user entered a wrong type
# of date), a function returns {:ok, result} and {:error, reason} accordingly.
# + For errors that are not part of normal operations (e.g. being unable to parse configuration data)
# you throw an exception.

# raise is used to raise an exception, it can have custom message as well

try do
  raise ArgumentError, message: "Some message"
rescue
  e in ArgumentError -> IO.inspect(e)
end

###################################################################################################
# After
###################################################################################################

# At times it may be necessary to perform some action after our try/rescue regardless of error.
# For this we have try/after.

{status, file} = File.open("LICENSE", [:read])
IO.puts(status)
IO.inspect(file)

try do
  line = IO.read(file, :line)
  IO.puts("first line: #{line}")
rescue
  e in RuntimeError -> IO.inspect(e.message)
after
  File.close(file)
end

###################################################################################################
# Custom errors
###################################################################################################

# Elixir includes a number of builtin error types like RuntimeError, we maintain the ability to
# create our own if we need something specific. Creating a new error is easy with the defexception/1
# macro which conveniently accepts the :message option to set a default error message:
defmodule CustomException do
  defexception message: "this is a custom error"
end

try do
  raise CustomException
rescue
  e in CustomException -> IO.inspect(e)
end

###################################################################################################
# Throws
###################################################################################################

# The throw/1 function gives us the ability to exit execution with a specific value we can catch:
try do
  for i <- 0..10 do
    if i == 5, do: throw(i)
    IO.puts(i)
  end
catch
  :throw, val -> IO.inspect("Caught #{val}")
end

###################################################################################################
# Exit
###################################################################################################

# Exit signals occur whenever a process dies and are an important part of the fault tolerance of
# Elixir.

# it is possible to catch an exit with try/catch doing so is extremely rare. In almost all cases it
# is advantageous to let the supervisor handle the process exit:

try do
  exit("oh no!")
catch
  :exit, msg -> IO.inspect("exit #{msg}")
end

spawn_link(fn -> exit("oh no") end)
