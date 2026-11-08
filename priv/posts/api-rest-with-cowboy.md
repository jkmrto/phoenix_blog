---
author: "Juan Carlos Martinez de la Torre"
date: 2019-01-09
linktitle: api-rest-cowboy
menu:
  main:
    parent: tutorials
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title: REST API with Cowboy
intro: In the Elixir world, the well-known framework Phoenix is the main tool for developing the client-facing side of any project. This framework allows us to build complex real-time web systems easily, with a lot of integrated features such as websockets. But if we just want to build a simple REST API, a good option is to use the **Cowboy** library, which makes the final application much more lightweight than using Phoenix.


---

In the [Elixir](https://elixir-lang.org/) world, the well-known framework **Phoenix** is the main tool for developing the client-facing side of any project. This framework allows us to build complex real-time web systems easily, with a lot of integrated features such as websockets. But if we just want to build a simple REST API, a good option is to use the **Cowboy** library, which makes the final application much more lightweight than using Phoenix.

In this post, I will show how to build a simple REST API service with **plug_cowboy**. This library makes it even easier to use **Cowboy**, which is a native Erlang library.

The code for this post is available in this [GitHub repository](https://github.com/jkmrto/api-rest-cowboy).


## Setup project

Create a new Elixir project:
```bash
mix new cowboy_example
```

Add the cowboy dependency to ```mix.exs```:

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

Let's use the ```lib/cowboy_rest.ex``` file as the application entrypoint for the supervision tree. We need to indicate this in our ```mix.exs``` file:



And set ```lib/cowboy_rest.exs``` as an application module, so its content will be:
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


We will create the folder ```lib/cowboy_rest```, where submodules will be placed. In our case, the only submodule will be the web one, at ```lib/cowboy_rest/web```.

## Cowboy files structure

At this point, we can start working with Cowboy in the Web submodule. We will need:

*   ```lib/cowboy_rest/web/supervisor```: The module defined in this file will be the Supervisor of the Web submodule. At startup, it will launch the ```http_listener```, which acts as the entrypoint for all requests.

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

*  ```lib/cowboy_rest/http_listener```: This file keeps the routing to the REST API handler functions. It is also in charge of launching the Cowboy listener at startup.


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

* ```lib/cowboy_rest/rest_handler```: A REST handler in charge of handling and answering incoming requests.


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

But to launch this submodule, we need to start our new Web supervisor from the application root, so the file ```ib/cowboy_rest.exs``` should look like this:

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

Now, if we run the application with ```iex -S mix```, we can try an HTTP request from the command line with **curl**:
```bash
> curl localhost:4000/cowboy_rest/welcome
Welcome to Cowboy Rest Services
```

As we can see, it is really easy to build a lightweight REST API application in Elixir using Cowboy.
