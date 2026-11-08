---
author: "Juan Carlos Martinez de la Torre"
date: 2019-03-23
linktitle: elixir-transient-supervisor
title: Elixir Transient Supervisor
intro: A few weeks ago, I was browsing the Elixir forum when I came across the question [Stop supervisor when no children are running anymore](https://elixirforum.com/t/stop-supervisor-when-no-children-are-running-anymore/20641). I tried to figure out a simple approach to get this done, so I checked the documentation of the [Supervisor](  https://hexdocs.pm/elixir/Supervisor.html#summary) module.


---


## Motivation

A few weeks ago, I was browsing the Elixir forum when I found this question: [Stop supervisor when no children are running anymore](https://elixirforum.com/t/stop-supervisor-when-no-children-are-running-anymore/20641). I tried to figure out a simple approach to get this done, so I checked the documentation of the [Supervisor](  https://hexdocs.pm/elixir/Supervisor.html#summary) module.

Apparently, there is no predefined option to kill a Supervisor when all its children die, so we need a workaround for this. The question specifies that the children implement the GenServer behaviour, which opens up a simple approach to detect when a child has died.

GenServer gives us the possibility to detect when the process is about to exit and perform some action, using the [terminate](https://hexdocs.pm/elixir/GenServer.html#c:terminate/2) callback. We can use this to check the number of processes associated with the supervisor and decide to kill it if there are no more children running under it.

For anyone interested, the code is available at this [repo](https://github.com/jkmrto/transient_supervisor).

## Getting hands dirty

So I decided to build a PoC to see how it would behave. First, we will need three components:

1. **Application entrypoint**. Supervision tree entrypoint.
2. **Transient Supervisor**. Supervisor that will die once all the workers are done.
3. **Worker**. Simple GenServer that will die once its task is done.


## Application entrypoint
From the entrypoint, we will start the transient supervisor. It is important to note that the restart type will be `restart: :transient`, in order to only restart the child if something goes wrong.

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

## Transient Supervisor

In this module, we should distinguish two parts:

1. The `start_link()` and `init()` functions are related to the normal supervisor implementation. Two children will be started: one of them will exit after 10 seconds and the other after 15 seconds. It is also important to note that the restart policy will again be `transient`.

2. The `stop_transient_supervisor()` is built with the idea of being called from an external process. This function checks whether any children are still alive; if there are none, the transient supervisor is stopped.

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

## Worker

This module contains the most interesting part of the code. When starting the GenServer, it receives as an argument the number of seconds to sleep before exiting, to simulate a real worker that will end at some point.

This number of seconds is used in `init(..)` with `Process.send_after(..)`, which sends a message to the process itself after that time, and then the GenServer stops.

This stop is trapped in the `terminate()` function. This function launches an external process that executes the `stop_transient_supervisor()` function defined in the transient supervisor module. It is important to note that we should avoid executing that function inside the GenServer process, since this would block the GenServer, so it wouldn't exit successfully.

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


## Running it

## Final notes

Although this seems like a valid approach that answers the initial question, we should reconsider whether it is a good pattern to start a supervisor and later kill it; maybe it is some kind of OTP antipattern. Ideally, a Supervisor should be something stable in the supervision tree.

Indeed, there is a [discussion](https://elixirforum.com/t/supervisor-dies-with-its-child/466/9?u=jkmrto) on the Elixir forum about something related. There are other approaches there that, although quite a bit more complex than the one in this post, seem like a better fit for the OTP world.
