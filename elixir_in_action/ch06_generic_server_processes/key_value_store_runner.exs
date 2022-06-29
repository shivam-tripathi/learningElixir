Code.load_file("key_value_store.exs", ".")

KeyValueStore.start()
KeyValueStore.put("hello", "world")
KeyValueStore.put("animal", "farm")
IO.inspect(KeyValueStore.get("animal"))
IO.inspect(KeyValueStore.get("hello"))
IO.inspect(KeyValueStore.terminate())
IO.inspect("terminated")

KeyValueStore.put("key", "value")

# First, GenServer.start/2 works synchronously. In other words, start/2 returns
# only after the init/1 callback has finished in the server process. Consequently, the
# client process that starts the server is blocked until the server process is initialized.
