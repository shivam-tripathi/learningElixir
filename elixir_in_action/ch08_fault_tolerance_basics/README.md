# Runtime Errors
## Types
1. errors,
- Examples:
	- ArithmeticError
	- UndefinedFunctionError
	- FunctionClauseError
- Raise errors:
	- raise("some error")
	- Convention: append ! to the function name if it explicitly raises an error
2. exits
- Deliberately terminate a process with a message
- Exit reason can be used for other process to detect a process crash
3. throws
- Allows for non local returns
- When we are deep in a loop, it's not trivial to stop the loop and return a value
- We can throw a value and catch it up the callstack
- It is hacky and not recommended (reminiscent of goto)
## Handling
```ex
try do
...
catch error_type, error_value ->
...
end
```
error_type would be one of :error, :exit, :throw.

```exs
try_helper = fn fun do ->
try do
	fun.()
	IO.puts("no error")
catch type, value ->
	IO.puts("Error\n #{inspect(error)} #{inspect(value)}")
end
end

try_helper.(fn -> raise("Something went wrong") end)
try_helper.(fn -> throw("thrown value") end)
try_helper.(fn -> exit("I'm done") end)
```
- Every thing is an expression which returns some value, the last statement in catch is the return value.
- We can do pattern matching in catch clause.
- `after` is always executed after the `try` block. It does not affect the result of the entire try expression.
- Try catch is not available for tail call optimisation.
- Use `defexception` macro to define custom macro.
- If runtime exception is not handled, the corresponding process will terminate.
- Ideally, we let the process crash and then do something (eg restart it).

# Errors in Concurrent Systems
- Isolated processes do not crash each other. Crashing process do not corrupt other process state.
```ex
spawn(
  fn ->
    spawn(
      fn ->
        Process.sleep(3000)
        IO.puts("process::2 finished")
      end
    )
    raise("something went wrong")
  end
)
```
- Process also communicate, in case of failure this may lead to client processes failing.
## Linking
- Detecting a process crash is via the concept of links. On a crash, an exit signal is sent to the other process. Exit signal contains pid of the crashed process and the exit reason. Normal termination has the reason :normal.
- By default, if the linked process receives an exit signal with reason not being :normal, it also crashes.
- One link connects two processes and is always bidirectional.
- `spawn_link` can be used to create linked processes. They are transitive in nature.
```ex
spawn(
  fn ->
    spawn_link(
      fn ->
        Process.sleep(1000)
        IO.puts("process::2 finished")
      end
    )
    raise("something went wrong")
  end
)
```
> p1 -> p2, p3 \
p2 -> p4 \
Suppose p4 crashes, then all p1, p2, p3 and p4 crash.

## Trapping exits
- Links break process isolation and propagate errors over process boundaries. It's like a notification channel for providing notifications about process terminations.
- Usually, we don't want linked process to crash - which we do by trapping exits.
```ex
spawn(
  fn ->
    spawn_link(
      fn ->
        Process.flag(:trap_exit, true)
        receive do
          msg -> IO.inspect(msg)
        end
        Process.sleep(1500)
        IO.puts("process::2 finished")
      end
    )
    Process.sleep(500)
    raise("something went wrong")
  end
)
```
## Monitors
- Sometimes we need unidirectional propagation.
- We can link two processes such that if one goes down, the other one is notified but not reverse using monitor. Only the process that created the monitor will be notified.
- In case of monitor, observer process will not crash in case the monitored process termintes.
- If monitored process dies, your process receives a message in the format {:DOWN, monitor_ref, :process, from_pid, exit_reason}. Default exit reason is :normal.
- We can demonitor using Process.demonitor(monitor_ref).
```ex
spawn(fn ->
  target_pid = spawn(fn -> Process.sleep(1000) end)
  monitor_ref = Process.monitor(target_pid)
  receive do
    msg -> IO.inspect(msg)
  end
end)
```
- While waiting for a response from the server, if a :DOWN message is received, GenServer can detect that a process has crashed and raise a corresponding exit signal in the client process. Internally, GenServer sets up a temporary monitor that targets the server process.
# Supervisors
- A Supervisor is a generic process that manages the lifecycle of other processes in a system.
- Using links, monitor and exit traps, Supervisor detects possible terminations of any child - and can restart it if required.
- Supervisor.start_link:
	- Supervisor traps exit, then starts the worker process.
	- If the worker terminates, Supervisor receives corresponding exit message and takes corrective action.
	- If Supervisor process terminates, it's children are also terminated.
	- Restart means another process with same module is started, which shares no state with the original process
	- First argument is list of workers - it specifies how the child should be started and managed.
	- Second argument is the list of Supervisor specific options. :strategy is restart strategy is mandatory (eg one_for_one etc).
	- Process should be registered, as they then allow for process discovery - given that they can be restarted with a different PID.
## Child Specification
- Specification
	- How should the child be started
	- What should be done if child terminates
	- How to uniquely distinguish each child
```ex
Supervisor.start_link(
	[%{id: Todo.Cache, start: { Todo.Cache, :start_link, [nil] } }],
	strategy: :one_for_one
)
```
This will instruct the Supervisor to invoke `Todo.Cache.start_link(nil)` to start the worker. One issue is - if something changes in function signature of the start function, we will have to make changes to adapt the specification in the code starting the Supervisor. To address this, Supervisor allows us to pass {module_name, arg} in child specification list. Supervisor will first invoke module_name.child_spec(arg) to get the actual specification. The default implementation is injected by GenServer, which is why we ignore the argument passed to start_link.
```ex
Supervisor.start_link(
  [{Todo.Cache, nil}],
  strategy: :one_for_one
)
```
## Restarts
- Default restart is 3 per 5 seconds
- Can be overriden using :max_restarts and :max_seconds
- When a critical process in the system crashes, it's Supervisor tries to bring it back online by starting new process. If restarting doesnt help, its clear that the problem cant be fixed and terminate itself. This is helpful in supervision trees.
