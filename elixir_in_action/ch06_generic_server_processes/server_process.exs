defmodule ServerProcess do
  def start(callback_module, initial_state \\ %{}) do
    spawn(fn -> loop(callback_module, initial_state) end)
  end

  # Server Process spawned at the time of start. It is synchronously executing messages from
  # mailbox.
  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)

      _ ->
        IO.puts("invalid message")
        loop(callback_module, current_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response

      _ ->
        nil
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end

defmodule KeyValueStore do
  def init do
    %{}
  end

  # request, state
  def handle_call({:put, key, value}, state) do
    {:ok, Map.merge(state, %{key => value})}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end

  def handle_cast(_, state) do
    state
  end

  def handle_call({:get_all}, state) do
    {state, state}
  end
end
