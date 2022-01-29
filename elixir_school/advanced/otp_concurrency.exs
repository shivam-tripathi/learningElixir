# An OTP server is a module with the GenServer behavior that implements a set of callbacks
# GenServer is a single process which runs a loop that handles one message per iteration passing
# along an updated state.

# a basic queue to store and retrieve values

defmodule SimpleQueue do
  use GenServer

  @doc """
  Start our queue and link it.
  This is a helper function
  """
  def start_link(state \\ []) do
    IO.inspect(__MODULE__)
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  To interact with GenServers in a synchronous way, calling a function and waiting for its response,
  we use GenServer.handle_call/3.
  handle_call takes in the request, the caller’s PID, and the existing state. It is expected to
  reply by returning a tuple: {:reply, response, state}.
  """
  def handle_call(:dequeue, _from, [value | state]) do
    {:reply, value, state}
  end

  def handle_call(:dequeue, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:queue, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Asynchronous requests are handled with the handle_cast/2 callback. This works much like
  handle_call/3 but does not receive the caller and is not expected to reply.
  """

  def handle_cast({:enqueue, item}, state) do
    {:noreply, state ++ [item]}
  end

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    {:ok, state}
  end

  def queue() do
    GenServer.call(__MODULE__, :queue)
  end

  def dequeue() do
    GenServer.call(__MODULE__, :dequeue)
  end

  def enqueue(item) do
    GenServer.cast(__MODULE__, {:enqueue, item})
  end
end

SimpleQueue.start_link([1, 2, 3])
IO.inspect(SimpleQueue.dequeue())
IO.inspect(SimpleQueue.dequeue())
SimpleQueue.enqueue(54)
IO.inspect(SimpleQueue.queue())
