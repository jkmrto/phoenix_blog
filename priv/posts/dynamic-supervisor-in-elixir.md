---
author: "Juan Carlos Martinez de la Torre"
date: 2019-02-03
linktitle: dynamic-supervisor
menu:
  main:
    parent: tutorials
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title: Dynamic Supervisor With Registry
description: This post will expose how to build a basic dynamic supervisor in Elixir.
weight: 10
---

One of the main feature of [Elixir](https://elixir-lang.org/ ) is the ability to guarantee that if a supervised process fails or get crashed for any reason, other process with the same functinality will be started as soon as the supervisor process realizes the problem. This is related to the fault-tolerance capability.

Let's say that we have an application in which at start we dont know how many processes we will have, because they will be generated dinamically during the running of the application. For example if we have a game application which allows several games at the same time and we want to get associated to each game one process, then we will need to dinamically launch a process per each game.

Since Elixir 1.6, [Dynamic Supervisor](https://hexdocs.pm/elixir/DynamicSupervisor.html)  is the module that makes simpler this task. In this post it will be exposed how to build a basic dynamic supervisor, using Elixir [Registry](https://hexdocs.pm/elixir/master/Registry.html) to keep reachable all the launched processes.

# Setup

Let's create a new project using ```mix``` through the command line with:
```Bash
mix new dynamic_supervisor_with_registry
```

We need to modify our file ```mix.exs``` to indicate the new application entrypoint:

```Elixir
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


# Components

## Application entrypoint

We need to use an application entrypoint where starts the supervision tree, the file. This module will be on charge of supervise the `Registry` and the `DynamicSupervisorWithRegistry.WorkerSupervisor`.

``` Elixir
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

  * **Registry** with name :workers_registry

  * **DynamicSupervisorWithRegistry.WorkerSupervisor**.

## Registry

The registry allows us to register the workers by a custom name (in our case *:workers_registry*), that will allow to acess the workers easily, without needing to know its *pid*, just by a custom name. It is launched at the same supervisor level that the **WorkersSupervisor** add will be referenced by workers at starting them.

## Workers Supervisor
This module should just supervise the workers and allow to launch new workers.

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
At the code above it is important to note:
* When starting a new child it is settled ```restart: :transient ```, what indicates that workers will be restarted only if they terminate due to an error not if it was a ```:normal``` termination. This configuration could be modified per each child.
* When ```init``` the process the restarting strategy selected is ```strategy: :one_for_one``` so only the crashed process will be restarted without affecting othersprocesses. 


## Worker

The worker module is a simple *GenServer*, in which we have just implemented some API functions and callbacks to handle a regular stop and a error crash. The idea is to test lately the different behaviour at the supervisor level when this action happens.

The name of the process will be defined by the function `via_tuple(name)`, whose code is ```{:via, Registry, {@registry, name} }``` that registers the process with custom `name` in the registry previously initialized with name ```:workers_registry```.
This ```via_tuple``` function will be used at registering and when trying to reach the associated GenServer.

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



# Running it

## Creating three workers
Let's use the interactive shell of elixir (```iex -S mix```) to run the code. To create three new workers:
 
```
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
At last command (```:observer.start()```) it has been launched the erlang observer that allows us to see the supervisor tree of the application.

![Example image](/images/dynamic_supervisor_with_registry/first.png)

We can see how the three pids (*#PID<0.138.0>, #PID<0.140.0>, #PID<0.142.0>*) of the workers created are now pendig from our workers supervisor.

## Stop one worker

Let's stop one of the workers to see how it is not restarted by the supervisor.

```
iex(7)> alias DynamicSupervisorWithRegistry.Worker
DynamicSupervisorWithRegistry.Worker

iex(8)> Worker.stop("worker_1")
:ok
16:31:45.596 [info]  Exiting worker: worker_1 with reason: :normal
```

The last message is printed by the logger at ```terminate(...)``` function. The process is not restarted since it has not been crashed.

## Crash one worker

Let's crash one of the workers to see how it is restarted by the supervisor
```
iex(11)> Worker.crash("worker_2")
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

Again we can identified the ```terminate``` message but in this case the reason of error is not ```:normal``` so it displays all the traces related to the error.

It also appears the error message that logs the error when the process crash. 

At last the ```Starting "worker_2"``` can be seen since the GenServer was restarted by the supervisor.

At ```observer``` we can see how the *worker_1* now doesnt appear while the *worker_2* has a different **pid** since it has been restarted.

![Example image](/images/dynamic_supervisor_with_registry/second.png)

We can see that the only worker process still alive is **#PID<0.142.0>** since it was the **pid** of the *worker_3* the one that has not been restared neither stopped.
