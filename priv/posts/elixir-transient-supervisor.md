---
author: "Juan Carlos Martinez de la Torre"
date: 2019-03-23
linktitle: elixir-transient-supervisor 
menu:
  main:
    parent: tutorials
title: Elixir Transient Supervisor
weight: 10
---

Some weeks ago I was visiting the elixir forum when I found this question: [Stop supervisor when no children are running anymore](https://elixirforum.com/t/stop-supervisor-when-no-children-are-running-anymore/20641). I tried to figure out a simple approach to get this done so I visited the documentation of the [Supervisor](  https://hexdocs.pm/elixir/Supervisor.html#summary) module. 

Apparently there is no way to kill a Supervisor when all his children die just using some predefined option, so we need to get some workaround for this. At the question it is specified that the childs will implement the GenServer behaviour, so this opens for us a simple approach to detect when a child has died. 

GenServer give us the possibility to track when the process is going to exit and do some action, that is using the [terminate](https://hexdocs.pm/elixir/GenServer.html#c:terminate/2) callback. We can use this to evaluate the number of processes associated to the supervisor and decide to kill it if there is no more children running under it.

For anyone interested, the code is available at this [repo](https://github.com/jkmrto/transient_supervisor).

# Getting hands dirty

So decided to build a PoC to see what will be the behaviour. At first what we will need would be three components:

1. **Application entrypoint**. Tree Supervision entrypoint.
2. **Transient Supervisor**. Supervisor that will died once all the workers are done.
3. **Worker**. Simple GenServer that will die once his task is done.


# Application entrypoint
From the entrypoint we will start the transient supervisor. It is important to note that the restart type will be `restart: :transient`, in order to only restart the child if there is some bad behaviour.

``` Elixir
defmodule TransientSupervisor.Application do
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      %{
        id: TransientSupervisor.TransientSupervisor,
        start: {TransientSupervisor.TransientSupervisor, :start_link, []},
        restart: :transient,
        type: :supervisor
      }
    ]

    opts = [strategy: :one_for_one, name: TransientSupervisor]
    Supervisor.start_link(children, opts)
  end
end
```

# Transient Supervisor

At this module we should differentiate two parts:

1. The `start_link()` and `init()` functions are related to the normal supervisor implementation. Two children will be started one of them will exit in 10 seconds and the other in 15 seconds. Also important to note that the restart policy will be again `transient`.

2. The `stop_transient_supervisor()` is built with the idea of being called from an external process. At this function it is evaluated if there are any children still alive, in case there is no more children alive the transient supervisor will be stopped.

``` Elixir
defmodule TransientSupervisor.TransientSupervisor do
  require Logger
  @moduledoc false

  use Supervisor

  def start_link(),
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg) do
    children = [
      %{
        id: :worker_10,
        start: {TransientSupervisor.Worker, :start_link, [[10], [name: :worker_10]]},
        restart: :transient
      },
      %{
        id: :worker_15,
        start: {TransientSupervisor.Worker, :start_link, [[15], [name: :worker_15]]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one, restart: :transient)
  end

  def stop_transient_supervisor() do
    case Supervisor.count_children(__MODULE__) do
      %{active: 0} ->
        Logger.debug("Let's destroy  the supervisor")
        Supervisor.stop(__MODULE__, :normal)

      _ ->
        :ok
    end
  end
end

```

# Worker

This module has the most interesting part of the code. When starting the GenServer, it receives as argument the seconds to sleep before exiting,  that is to simulate a real worker that will end at some point.

This number of seconds is sent at the `init(..)` using `Process.send_after(..)`, sending a message to the own process in order to sleep for that seconds and then stops the GenServer. 

This stop is trapped at the `terminate()` function. This function launches an external process that will execute the function  `stop_transient_supervisor()` defined at the transient supervisor module. It is important to note that we should avoid executing the function inside the GenServer process since this will block the GenServer, so it wont exit succesfully.

```Elixir
defmodule TransientSupervisor.Worker do
  require Logger
  use GenServer

  #######
  # API #
  #######

  def start_link([seconds_to_end], opts),
    do: GenServer.start_link(__MODULE__, [seconds_to_end], opts)

  ##############
  # Callbackes #
  ##############

  def init([seconds_to_sleep]) do
    Process.send_after(self(), {:do_task, seconds_to_sleep}, 1_000)
    {:ok, []}
  end

  def handle_info({:do_task, secs_to_sleep}, state) do
    Logger.debug("#{inspect(self())} task will end in #{inspect(secs_to_sleep)} seconds")
    :timer.sleep(secs_to_sleep * 1000)
    {:stop, :normal, state}
  end

  def terminate(_reason, state) do
    Logger.debug("#{inspect(self())} task is exiting")
    Task.start(TransientSupervisor.TransientSupervisor, :stop_transient_supervisor, [])
    {:ok, state}
  end
end
```


# Running it

# Final notes

Although this seems like a valid approach that can fulfill the initial question, we should reconsider if it is good pattern to start a supervisor and later kill it, maybe we are doing some kind of OTP antipattern. Ideally a Supervisor should be something stable at the supervision tree.

Indead there is a [discussion](https://elixirforum.com/t/supervisor-dies-with-its-child/466/9?u=jkmrto) at Elixir forum where something related to this has been already posted. There other approaches that although can be quite more complex that the one posted here, they seems like a better appraoch at the OTP world.




