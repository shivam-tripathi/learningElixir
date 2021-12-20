defmodule KV.Bucket do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  def del(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  def incr(bucket, key, value) do
    IO.inspect(bucket: bucket, key: key, value: value)
    Agent.update(bucket, &Map.put(&1, key, Map.get(&1, key, 0) + value))
  end
end

# When a long action is performed on the server, all other requests to that particular
# server will wait until the action is done, which may cause some clients to timeout.
# So it is important to ensure every action on server is short lived and if there's any heavy
# lifting is required, it can be done on the client itself
