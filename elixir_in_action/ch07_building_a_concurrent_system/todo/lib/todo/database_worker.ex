defmodule Todo.DatabaseWorker do
  use GenServer

  def start(id, db_loc) do
    GenServer.start(__MODULE__, [db_loc: db_loc, id: id])
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def store_optimised(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store_optimised, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  def get_optimised(worker_pid, key) do
    GenServer.call(worker_pid, {:get_optimised, key})
  end

   # @spec file_name(PID) :: String.t()
   defp file_name(name, db_loc) do
    Path.join(db_loc, to_string(name))
  end

  @impl GenServer
  def init(state) do
    File.mkdir_p!(state[:db_loc])
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state[:db_loc])
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:store_optimised, key, data}, state) do
    spawn(fn ->
      key
      |> file_name(state[:db_loc])
      |> File.write(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key, state[:db_loc])) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  @impl GenServer
  def handle_call({:get_optimised, key}, caller, state) do
    spawn(fn ->
      data =
        case File.read(file_name(key, state[:db_loc])) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end
      GenServer.reply(caller, data)
    end)

    # no reply from callback
    {:noreply, state}
  end
end
