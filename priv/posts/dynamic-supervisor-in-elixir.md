---
author: "Juan Carlos Martinez de la Torre"
date: 2019-02-03
linktitle: dynamic-supervisor
title: Dynamic Supervisor With Registry
intro: One of the main features of [Elixir](https://elixir-lang.org/ ) is the ability to guarantee that if a supervised process fails or crashes for any reason, another process with the same functionality will be started as soon as the supervisor notices the problem. This is related to its fault-tolerance capabilities.

---

## Motivation

One of the main features of [Elixir](https://elixir-lang.org/ ) is the ability to guarantee that if a supervised process fails or crashes for any reason, another process with the same functionality will be started as soon as the supervisor notices the problem. This is related to its fault-tolerance capabilities.

Let's say we have an application where, at startup, we don't know how many processes we will have, because they will be generated dynamically while the application runs. For example, if we have a game application that allows several games at the same time and we want to associate one process with each game, we will need to dynamically launch a process for each game.

Since Elixir 1.6, [Dynamic Supervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html)  is the module that makes this task simpler. This post shows how to build a basic dynamic supervisor, using Elixir's [Registry](https://hexdocs.pm/elixir/master/Registry.html) to keep all the launched processes reachable.

## Setup

Let's create a new project using ```mix``` through the command line with:
```shell
mix new dynamic_supervisor_with_registry
```

We need to modify our ```mix.exs``` file to indicate the new application entrypoint:

```elixir
............
#mix.exs
  def application do
    [
      mod: {DynamicSupervisorWithRegistry, []},
      extra_applications: [:logger]
    ]
  end
............
```


## Components

### Application entrypoint

We need an application entrypoint where the supervision tree starts. This module will be in charge of supervising the `Registry` and the `DynamicSupervisorWithRegistry.WorkerSupervisor`.

```elixir
#lib/dynamic_supervisor_example.ex
defmodule DynamicSupervisorWithRegistry do
  use Application # Indicate this module is an application entrypoint

  @registry :workers_registry

  def start(_args, _opts) do
    children = [
      { DynamicSupervisorWithRegistry.WorkersSupervisor, [] },
      { Registry, [keys: :unique, name: @registry]}
    ]

    # :one_to_one strategy indicates only the crashed child will be restarted, without affecting the rest of children.
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
```

As children of this module we have:

- **Registry** with name `:workers_registry`.
- **DynamicSupervisorWithRegistry.WorkerSupervisor**.

### Registry

The registry (in our case `:workers_registry`) allows us to register the workers under a custom name, which lets us access them easily without needing to know their *pid*. This registry is launched at the same supervision level as the **WorkersSupervisor**.

### Workers Supervisor
This module should just supervise the workers and allow launching new ones.

``` Elixir
# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule DynamicSupervisorWithRegistry.WorkersSupervisor do
  use DynamicSupervisor
  alias DynamicSupervisorWithRegistry.Worker

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(child_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Worker, start: { Worker, :start_link,  [child_name]}, restart: :transient})
  end

end
```
In the code above, it is important to note:
* When starting a new child, ```restart: :transient ``` is set, which means workers will be restarted only if they terminate due to an error, not on a ```:normal``` termination. This configuration could be changed for each child.
* In ```init```, the selected restart strategy is ```strategy: :one_for_one```, so only the crashed process will be restarted, without affecting other processes.


### Worker

The worker module is a simple *GenServer*, in which we have implemented some API functions and callbacks to handle a regular stop and a crash. Later, we will test the different behaviour at the supervisor level when a crash happens. 

The name of the process will be defined by the function `via_tuple(name)`, whose code is ```{:via, Registry, {@registry, name} }``` which registers the process with a custom `name` in the registry previously initialized with the name ```:workers_registry```.
This ```via_tuple``` function will be used when registering the process and when trying to reach the associated GenServer.

The `terminate(reason, name)` callback will be called when the process is exiting.

```Elixir
# lib/dynamic_supervisor_example/worker.ex
defmodule DynamicSupervisorWithRegistry.Worker do
  use GenServer
  require Logger

  @registry :workers_registry

  ## API
  def start_link(name),
    do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def stop(name), do: GenServer.stop(via_tuple(name))

  def crash(name), do: GenServer.cast(via_tuple(name), :raise)

  ## Callbacks
  def init(name) do
    Logger.info("Starting #{inspect(name)}")
    {:ok, name}
  end

  def handle_cast(:work, name) do
    Logger.info("hola")
    {:noreply, name}
  end

  def handle_cast(:raise, name),
    do: raise RuntimeError, message: "Error, Server #{name} has crashed"

  def terminate(reason, name) do
    Logger.info("Exiting worker: #{name} with reason: #{inspect reason}")
  end

  ## Private
  defp via_tuple(name) ,
    do: {:via, Registry, {@registry, name} }

end
```



## Running it

### Creating three workers
Let's use Elixir's interactive shell (```iex -S mix```) to run the code. To create three new workers:

```elixir
iex(1)> alias DynamicSupervisorWithRegistry.WorkersSupervisor
DynamicSupervisorWithRegistry.WorkersSupervisor

iex(2)> WorkersSupervisor.start_child("worker_1")
14:21:45.527 [info]  Starting "worker_1"
{:ok, #PID<0.138.0>}

iex(3)> WorkersSupervisor.start_child("worker_2")
14:21:45.529 [info]  Starting "worker_2"
{:ok, #PID<0.140.0>}

iex(4)> WorkersSupervisor.start_child("worker_3")
14:21:45.529 [info]  Starting "worker_3"
{:ok, #PID<0.142.0>}

iex(5)> :observer.start()
```
The last command (```:observer.start()```) launches the Erlang observer, which allows us to see the supervision tree of the application.

![Example image](/images/dynamic_supervisor_with_registry/first.png)

We can see how the three pids (*#PID<0.138.0>, #PID<0.140.0>, #PID<0.142.0>*) of the created workers now hang from our workers supervisor.

### Stop one worker

Let's stop one of the workers to see that it is not restarted by the supervisor.

```elixir
iex(7)> alias DynamicSupervisorWithRegistry.Worker
DynamicSupervisorWithRegistry.Worker

iex(8)> Worker.stop("worker_1")
:ok
16:31:45.596 [info]  Exiting worker: worker_1 with reason: :normal
```

The last message is printed by the logger in the ```terminate(...)``` function. The process is not restarted, since it did not crash.

### Crash one worker

Let's crash one of the workers to see how it is restarted by the supervisor:
```elixir
Worker.crash("worker_2")
:ok

16:39:24.410 [info]  Exiting worker: worker_2 with reason: {%RuntimeError{message: "Error, Server worker_2 has crashed"}, [{DynamicSupervisorWithRegistry.Worker, :handle_cast, 2, [file: 'lib/dynamic_supervisor_with_registry/worker.ex', line: 28]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 637]}, {:gen_server, :handle_msg, 6, [file: 'gen_server.erl', line: 711]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 249]}]}

16:39:24.410 [error] GenServer {:workers_registry, "worker_2"} terminating

iex(12)>
** (RuntimeError) Error, Server worker_2 has crashed
    (dynamic_supervisor_example) lib/dynamic_supervisor_with_registry/worker.ex:28: DynamicSupervisorWithRegistry.Worker.handle_cast/2
    (stdlib) gen_server.erl:637: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:711: :gen_server.handle_msg/6
    (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
Last message: {:"$gen_cast", :raise}
State: "worker_2"

16:39:24.411 [info]  Starting "worker_2"
```

Again, we can identify the ```terminate``` message, but in this case the reason is not ```:normal```, so it displays all the traces related to the error.

The error message logged when the process crashes also appears.

Finally, ```Starting "worker_2"``` can be seen, since the GenServer was restarted by the supervisor.

In ```observer```, we can see that *worker_1* no longer appears, while *worker_2* has a different **pid**, since it has been restarted.

![Example image](/images/dynamic_supervisor_with_registry/second.png)

We can see that the only original worker process still alive is **#PID<0.142.0>**, since it was the **pid** of *worker_3*, which was neither restarted nor stopped.
