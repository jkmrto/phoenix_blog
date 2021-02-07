---
author: "Juan Carlos Martinez de la Torre"
date: 2019-01-09
linktitle: api-rest-cowboy
menu:
  main:
    parent: tutorials
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title: Api Rest With Cowboy
description: This tutorial will explain how to create a simple API REST with cowboy(plug_cowboy)
weight: 10
---

At [Elixir](https://elixir-lang.org/) world the well know framework **Phoenix** is the main tool to develop the client side interface in any project. This framework allows us to develop complex real-time web systems simply with a lot of integrated features such as websockets. But in the case of just pretending to build a simple api rest a good option is to use the **Cowboy** library, which makes quite more lightweight the final application than using Phoenix.

In this post I will expose how to build a simple Rest Api Service with **plug_cowboy**. This library makes even easier to use the **Cowboy** library, which is native from Erlang.

The code of this post is availabe at this [github repository](https://github.com/jkmrto/api-rest-cowboy). 


## Setup project

Create New project with Elixir
```bash
mix new cowboy_example
```

Add cowboy dependency at ```mix.exs```

``` elixir
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"}
    ]
  end
```

Let's get and compile this dependency:
```bash
mix deps.get && mix deps.compile
```

## Application entrypoint

Let's use the ```lib/cowboy_rest.ex``` file as application entrypoint for the supervision tree. We need to indicate this on our ```mix.exs``` file:



And set ```lib/cowboy_rest.exs``` as an application module so his content will be:
``` Elixir
defmodule CowboyRest do
  use Application

  def start(_type, _args) do
    children = [
    # No childrent yet
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
```


We will create the folder ```lib/cowboy_rest``` where submodules will be included. In our case the only submodule will be the web one at ```lib/cowboy_rest/web```.

## Cowboy files structure

At this point we can start working on Cowboy on the Web submodule. We will need:

*   ```lib/cowboy_rest/web/supervisor```: The module defined in this file will be the Supervisor of the Web submodule. At start it will launch the ```http_listener``` that behaves as entrypoints for all the requests.

```elixir
defmodule CowboyRest.Web.Supervisor do
  @moduledoc false
  use Supervisor

   def start_link(_arg, _opts) do
     Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
   end

   def init(_arg) do
     children = [
       worker(CowboyRest.Web.HttpListener, [[], []])
     ]

     supervise(children, strategy: :one_for_one)
   end
 end
```

*  ```lib/cowboy_rest/http_listener```: This file will keep the routing to the api Rest Handler functions. This will be also in charge of launching Cowboy Listener at start.


```elixir
defmodule CowboyRest.Web.HttpListener do
  alias CowboyRest.Web.Handler
  alias Plug.Cowboy
  require Logger

  def start_link(_state, _opts) do
    Logger.info ("API Rest is working ...")
    options = [
      port: 4000,
      dispatch: [ { host(), routes() } ],
    ]
    Cowboy.http(__MODULE__, [], options)
  end

  def host(), do: :_

  def routes() do
    [
      {"/cowboy_rest/[...]", Cowboy.Handler, { Handler, [] }},
    ]
  end
end
```

* ```lib/cowboy_rest/rest_handler```: It is a Rest Handler in charge of handling and answering the incoming requests.


```elixir
defmodule CowboyRest.Web.Handler do
  use Plug.Router
  require Logger

  plug :match
  plug :dispatch

  @content_type_header_key    "content-type"
  @html_header_value          "text/html"
  @entrypoint                 "/cowboy_rest/"

  get @entrypoint <> "/welcome" do
    Plug.Conn.fetch_query_params(conn) # populates conn.params
    |> put_resp_header(@content_type_header_key, @html_header_value)
    |> send_resp(200, "Welcome to CowboyRest Service")
  end

 end
```

But in order to launch this submodule we need to launch our new Web supervisor from the application root, so the file ```ib/cowboy_rest.exs``` should look like this:

```Elixir
defmodule CowboyRest do
  use Application

  def start(_type, _args) do
    children = [
    # No childrent yet
    ]

    Supervisor.start_link(children, [])
  end
end

```

## Running it

Now if we run the application with ```iex -S mix```, we can try a http request trough the command line with **curl**:
```bash
> curl localhost:4000/cowboy_rest/welcome
Welcome to Cowboy Rest Services
```

We can see how it is really easy to have a lightweigth API Rest application on elixir using Cowboy.
