defmodule DatabaseServer do
  def start do
    connection = :rand.uniform(1000)
    spawn(fn -> loop(%{connection: connection}) end)
  end

  defp loop(state) do
    IO.inspect(state)

    receive do
      {:run_query, caller, query} ->
        state = Map.merge(%{query => true}, state)
        send(caller, {:query_result, run_query(query)})
        loop(state)

      _ ->
        loop(state)
    end
  end

  defp run_query(query) do
    Process.sleep(2000)
    "query_result #{query}"
  end

  def run_query_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  def get_result() do
    receive do
      {:query_result, result} ->
        result
    after
      5000 -> {:error, :timeout}
    end
  end
end
