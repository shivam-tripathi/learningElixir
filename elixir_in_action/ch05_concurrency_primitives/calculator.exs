defmodule Calculator do
  def start(start_value \\ 0) do
    spawn(fn -> loop(start_value) end)
  end

  defp loop(current_value) do
    new_value =
      receive do
        msg ->
          process_message(current_value, msg)
      end

    loop(new_value)
  end

  def process_message(current_value, {:value, caller}) do
    send(caller, {:response, current_value})
    current_value
  end

  def process_message(current_value, {:add, value}) do
    current_value + value
  end

  def process_message(current_value, {:sub, value}) do
    current_value - value
  end

  def process_message(current_value, {:mult, value}) do
    current_value * value
  end

  def process_message(current_value, {:div, value}) do
    current_value / value
  end

  def process_message(current_value, invalid_request) do
    IO.puts("invalid request #{invalid_request}")
    current_value
  end

  # This method blocks
  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} ->
        value
    end
  end

  # All these are async in nature
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mult(server_pid, value), do: send(server_pid, {:mult, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
end
