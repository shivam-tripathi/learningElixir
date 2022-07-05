<!-- livebook:{"persist_outputs":true} -->

  # Todo Supervised

  ## Section

  ```elixir
  defmodule Todo.DatabaseWorker do
    use GenServer

    def start_link(id, db_loc) do
      GenServer.start_link(__MODULE__, db_loc: db_loc, id: id)
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

  defmodule Todo.Database do
    use GenServer

    @db_loc "./persist/persist"
    @num_workers 3

    @spec start_link :: :ignore | {:error, any} | {:ok, pid}
    def start_link do
      workers =
        Enum.map(1..@num_workers, fn id ->
          {:ok, pid} = Todo.DatabaseWorker.start_link(id, "#{@db_loc}_#{id}")
          pid
        end)

      GenServer.start_link(__MODULE__, [workers: workers], name: __MODULE__)
    end

    @impl GenServer
    def init(state) do
      {:ok, state}
    end

    def choose_worker(key, workers) do
      idx = :erlang.phash2(key, @num_workers) - 1
      Enum.at(workers, idx)
    end

    @spec store(any, any) :: :ok
    def store(key, data) do
      GenServer.cast(__MODULE__, {:store, key, data})
    end

    @impl GenServer
    def handle_cast({:store, key, data}, state) do
      Todo.DatabaseWorker.store(choose_worker(key, state[:workers]), key, data)
      {:noreply, state}
    end

    def get(key) do
      GenServer.call(__MODULE__, {:get, key})
    end

    @impl GenServer
    def handle_call({:get, key}, caller, state) do
      spawn(fn ->
        data = Todo.DatabaseWorker.get(choose_worker(key, state[:workers]), key)
        GenServer.reply(caller, data)
      end)

      {:noreply, state}
    end
  end

  defmodule Todo.List do
    @spec new :: %{}
    def new(), do: %{}

    @spec add_entry(map, %{:date => Date, :title => String, optional(any) => any}) :: map
    def add_entry(todo_list, new_entry) do
      %{title: title, date: date} = new_entry
      Map.update(todo_list, date, [title], fn existing_value -> [title | existing_value] end)
    end

    @spec entries(map, Date) :: [String.t()]
    def entries(todo_list, date) do
      Map.get(todo_list, date, [])
    end
  end

  defmodule Todo.Server do
    use GenServer

    def start_link(name) do
      GenServer.start_link(__MODULE__, name)
    end

    @impl GenServer
    def init(name) do
      send(self(), {:init, name})
      {:ok, nil}
    end

    @impl GenServer
    def handle_info({:init, name}, _) do
      db = Todo.Database.get(name)
      {:noreply, {name, db || Todo.List.new()}}
    end

    @spec add_entry(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
    def add_entry(todo_server, entry) do
      GenServer.cast(todo_server, {:add, entry})
    end

    @impl GenServer
    def handle_cast({:add, entry}, {name, cur_list}) do
      new_list = Todo.List.add_entry(cur_list, entry)
      # can cause backpressure issues
      Todo.Database.store(name, new_list)
      {:noreply, {name, new_list}}
    end

    def entries(todo_server, date) do
      GenServer.call(todo_server, {:entries, date})
    end

    @impl GenServer
    def handle_call({:entries, date}, _, {name, cur_list}) do
      entries = Map.get(cur_list, date, [])
      {:reply, entries, {name, cur_list}}
    end
  end

  defmodule Todo.Cache do
    use GenServer

    def start_link(_) do
      GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end

    def server_process(todo_list_name) do
      GenServer.call(__MODULE__, {:server_process, todo_list_name})
    end

    def cache_size() do
      GenServer.call(__MODULE__, {:cache_size})
    end

    @impl GenServer
    def init(_) do
      Todo.Database.start_link()
      {:ok, %{}}
    end

    @impl GenServer
    def handle_call({:server_process, todo_list_name}, _, state) do
      case Map.fetch(state, todo_list_name) do
        {:ok, todo_server} ->
          {:reply, todo_server, state}

        :error ->
          {:ok, todo_server} = Todo.Server.start_link(todo_list_name)
          {:reply, todo_server, Map.put(state, todo_list_name, todo_server)}
      end
    end

    @impl GenServer
    def handle_call({:cache_size}, _, state) do
      {:reply, map_size(state), state}
    end

    def handle_call(request, _, state) do
      {:reply, request, state}
    end
  end

  defmodule Todo.System do
    use Supervisor

    def start_link do
      Supervisor.start_link(__MODULE__, nil)
    end

    def init(_) do
      Supervisor.init(
        [Todo.Cache],
        strategy: :one_for_one
      )
    end
  end
  ```

  <!-- livebook:{"output":true} -->

  ```
  {:module, Todo.System, <<70, 79, 82, 49, 0, 0, 8, ...>>, {:init, 1}}
  ```

  ```elixir
  :erlang.system_info(:process_count)
  ```

  <!-- livebook:{"output":true} -->

  ```
  69
  ```

  ```elixir
  Todo.System.start_link()
  ```

  <!-- livebook:{"output":true} -->

  ```
  {:ok, #PID<0.294.0>}
  ```

  ```elixir
  :erlang.system_info(:process_count)
  ```

  <!-- livebook:{"output":true} -->

  ```
  75
  ```

  ```elixir
  pid = Process.whereis(Todo.Cache)
  Process.exit(pid, :exit)
  ```

  <!-- livebook:{"output":true} -->

  ```
  true
  ```

  ```elixir
  :erlang.system_info(:process_count)
  ```

  <!-- livebook:{"output":true} -->

  ```
  75
  ```
