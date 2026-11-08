---
author: "Juan Carlos Martinez de la Torre"
date: 2019-09-11
linktitle: erlang-distributed-with-docker-and-libcluster
title: Distributed Erlang with Docker and libcluster
weight: 10
intro: These last few days, I have been diving a little into the wonderful world of distributed Erlang. Elixir has some built-in constructs for distributed systems, which make it easier to build distributed systems compared with other programming paradigms.

---

## Motivation

These last few days, I have been diving a little into the wonderful world of distributed Erlang. Elixir has some built-in constructs for distributed systems, which make it easier to build distributed systems compared with other programming paradigms.

Since Erlang is based on the actor model (where each actor is a process), it is transparent to Erlang whether an actor is local or on a remote host, as long as the nodes are connected.

Another tool I love to use is Docker, so I started to dive into how to connect two dockerized Elixir instances. It has some tricks that we will discover throughout this post.

## Connecting dockers with --net=host

In this first attempt, we are going to launch two Docker containers using the latest Elixir image, with two `iex` terminals open where we can play with the nodes.

```shell
$ docker run -i -t --net=host elixir iex --sname node1 --cookie cookie
```
And our second node:
```zsh
$ docker run -i -t --net=host elixir iex --sname node2 --cookie cookie
```

 By using the [--net=host](https://docs.docker.com/network/host/) option, the two containers share the same network interface, so this scenario is quite similar to launching the two Elixir instances locally.

Let's check if our two nodes are connected:

```elixir
# Node2
> Node.list()
[]
```
This means that the nodes are not connected yet. We need to request the connection:

```Elixir
Node2
> Node.connect([:"node1@jkmrto-XPS-15-9570"])
true
```

Now our nodes are connected. We can check it:

```Elixir
iex(node2@jkmrto-XPS-15-9570)4> Node.list()
[:"node1@jkmrto-XPS-15-9570"]
```

Another way to check the connectivity with another node is using [:net_admin:ping()](http://Erlang.org/doc/man/net_adm.html#ping-1):

```elixir
# Node1
> :net_adm.ping(:node1@jkmrto-XPS-15-9570)
Pong

> Node.list()
[:"node1@jkmrto-XPS-15-9570"]
```

## Connecting nodes with Libcluster

One useful library for connecting our nodes is [libcluster](https://github.com/bitwalker/libcluster). As its own documentation states:

> `This library provides a mechanism for automatically forming clusters of Erlang nodes`.

### Libcluster POC

Let's build a simple proof of concept with libcluster to run some tests on it.

- Create the project:


```Bash
mix new libcluster_poc
```

Let's add the dependency to the mix file. Remember to check the latest version on [hex](https://hex.pm/packages/libcluster)

```Elixir
#./mix.exs
...
defp deps do
  [
    {:libcluster, "~> 3.1.1"}
  ]
end
...
```

Let's add the application entrypoint:

```Elixir
#./mix.exs
...
def application do
  [
    extra_applications: [:logger],
    mod: {LibclusterPoc, []}
  ]
end
...
```

Let's add the module that is called at the entrypoint:

```Elixir
# ./lib/libcluster_poc.ex
defmodule LibclusterPoc do
  use Application

  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"node1@jkmrto-XPS-15-9570",
            :"node2@jkmrto-XPS-15-9570",
            :"node3@jkmrto-XPS-15-9570"
          ]
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: :cluster_supervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LibclusterPoc)
  end
end
```

It is important to note this:

- The strategy used by Libcluster is `Cluster.Strategy.Epmd`, which relies on Epmd to connect the different hosts.
- Three nodes have been specified to be connected.

### Executing three instances locally

Let's launch the three instances locally and check how the nodes are automatically connected.


```Elixir
# First node
jkmrto:libcluster_poc/ $ iex --sname node1 --cookie cookie -S mix
[libcluster:example] unable to connect to :"node2@jkmrto-XPS-15-9570"
[libcluster:example] unable to connect to :"node3@jkmrto-XPS-15-9570"
```

```Elixir
# Second node
jkmrto:libcluster_poc/ $ iex --sname node2 --cookie cookie -S mix
[libcluster:example] connected to :"node1
[libcluster:example] unable to connect to :"node3@jkmrto-XPS-15-9570"
```

```Elixir
# Third node
jkmrto:libcluster_poc/ $ iex --sname node3 --cookie cookie -S mix
[libcluster:example] connected to :"node1@jkmrto-XPS-15-9570"
[libcluster:example] connected to :"node2@jkmrto-XPS-15-9570"
> Node.list()
[:"node1@jkmrto-XPS-15-9570", :"node2@jkmrto-XPS-15-9570"]
```

Amazing! We can see that, after running the third node, its logs indicate that the nodes have been correctly connected. So in the end, all we have to do to connect the nodes is specify the list of nodes when starting the application.


### Checking the Epmd

One interesting part of the Erlang ecosystem is the Erlang Port Mapper Daemon, also known as [Epmd](http://Erlang.org/doc/man/epmd.html). This service is in charge of mapping each Erlang node to the port where it is listening for connections.

An Epmd server is started as soon as one Erlang node starts. If another Erlang node is launched on the same host, then the `{port, node_name}` pair will be added to the already running epmd.


We can check the Erlang nodes running on our machine using the epmd service. The epmd executable is located in the same folder as the `erl` binary.
```shell
> which erl
/home/jkmrto/.asdf/shims/erl
> cd /home/jkmrto/.asdf/shims
> epmd -names
epmd: up and running on port 4369 with data:
name node3 at port 39099
name node2 at port 44643
name node1 at port 45015
```


## Connecting three instances dockerized

### Dockerizing the application

Let's use this simple dockerfile:

```dockerfile
# ./dockerfile
FROM elixir:1.9.4-slim

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mkdir -p /opt/libcluster_poc
ADD ./config /opt/libcluster_poc/config
ADD ./lib /opt/libcluster_poc/lib
ADD ./mix.exs /opt/libcluster_poc


WORKDIR /opt/libcluster_poc
RUN mix deps.get && mix compile

ENTRYPOINT [ "iex", "-S",  "mix" ]
```

Let's build and try it:

```
> docker build -t libcluster_poc .
```

And running it:

``` Elixir
> docker run -it  libcluster_poc

Erlang/OTP 22 [erts-10.5.4] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe]

17:44:20.079 [warn]  [libcluster:example] unable to connect to :"node1@jkmrto-XPS-15-9570": not part of network

17:44:20.080 [warn]  [libcluster:example] unable to connect to :"node2@jkmrto-XPS-15-9570": not part of network

17:44:20.080 [warn]  [libcluster:example] unable to connect to :"node3@jkmrto-XPS-15-9570": not part of network
Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

### Using docker network

Once we have our Docker image defined, we need to start thinking about how to connect several containers. Let's now use an internal Docker network, avoiding the `--net=host` trick.

Let's create the network, calling it `net_poc`:

```Elixir
docker network create net_poc
```

### Custom docker run

Let's run our Docker instances. We are going to need some options in order to get the expected behavior.

These options are:

- `-it`: It is required to start an interactive session.
- `--net net_poc`: It is required to attach the container to the network created previously.
- `--name`: This is the name used by the [docker DNS](https://docs.docker.com/v17.09/engine/userguide/networking/configure-dns/) to resolve the container's location inside our custom network. It is also the name that identifies the container when executing `docker ps`.
- `--hostname`: This will be the hostname of the launched container. It is used by Erlang to fully qualify the Erlang node name.
- `--entrypoint=iex libcluster_poc --cookie cookie --sname node1 -S mix`: This syntax defines the Docker image to be executed and a custom entrypoint, which needs to be different for each container in order to customize the name of the Erlang node with the `-sname` flag.
    - `--entrypoint=iex`: Executable to be run when starting the container.
    - `libcluster_poc`: Docker image to be executed.
    - `--cookie cookie --sname node1 -S mix`: Entrypoint arguments.

```Elixir
# Node1
> docker run -it --net net_poc --hostname node1 --name node1 --entrypoint=iex libcluster_poc --cookie cookie --sname node1 -S mix
```

``` Elixir
# Node2
> docker run -it --net net_poc --hostname node2 --name node2 --entrypoint=iex libcluster_poc --cookie cookie --sname node2 -S mix
```


Once both are launched, we can check that there is connectivity between them:

``` Elixir
# Node1
> Node.ping(:node2@node2)
pong
```

``` Elixir
# Node2
> Node.ping(:node1@node1)
pong
```

Great! We have two fully connected containers.

It is important to note that the nodes are not connected when they start; they get connected when calling `Node.ping/1`. The next step is connecting them at startup.

### Automatic connection with Libcluster

We just need to redefine the nodes in the Libcluster topologies to get them automatically connected at startup.

```Elixir
#./lib/libcluster_poc.ex
...
topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :node1@node1,
            :node2@node2
          ]
        ]
      ]
    ]
```

Let's rebuild the Docker image:


```
> docker build -t libcluster_poc .
```

Let's run our dockers:

```Elixir
# Node1
> docker run -it --net net_poc --hostname node1 --name node1 --entrypoint=iex libcluster_poc --cookie cookie --sname node1 -S mix
[libcluster:example] unable to connect to :node2@node2
```

``` Elixir
# Node2
> $ docker run -it --net net_poc --hostname node2 --name node2 --entrypoint=iex libcluster_poc --cookie cookie --sname node2 -S mix
[libcluster:example] connected to :node1@node1
```

Wonderful! Now our two nodes are connected at startup thanks to Libcluster.

## Connecting Dockers using DNS autodiscovery

Until now, we have had to explicitly specify which nodes are going to be connected in the libcluster configuration.

Let's think about a possible scenario where we don't know the number of containers that are going to be available in our imaginary cluster. In that case, we will have to think about a way to autodiscover the nodes of our cluster.

When working with Docker and custom networks, a useful option in this scenario is `--net-alias`, which sets a custom alias that can be assigned to as many containers as we want.

This shared alias can be used to autodiscover all the available containers that have been labeled with the alias.

### Checking DNS autodiscovery.

Let's launch two nodes with the same `--net-alias`, `web`. We should be able to get the addresses of these nodes by asking the Docker DNS.

```Bash
# Node 1
$ docker run -it --net net_poc --net-alias web elixir bash
root@a88f2309b047:$ ip addr show eth0
66: eth0@if67: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:1a:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.26.0.3/16 brd 172.26.255.255 scope global eth0
```

The IP for our first node is `172.26.0.3`. Let's launch the second one:

```Bash
# Node 2
$ docker run -it --net net_poc --net-alias web elixir bash
root@24bc556b10b3:$ ip addr show eth0
64: eth0@if65: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:1a:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.26.0.2/16 brd 172.26.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

The IP for the second node is `172.26.0.2`.

Now we should be able to retrieve the addresses of these two hosts by launching a new container connected to the same network and asking the DNS for the `web` alias.

```Elixir
# Node 3
jkmrto:~ $ docker run -it --net net_poc elixir
> :inet.gethostbyname(:web)
{:ok, {:hostent, 'web', [], :inet, 4, [{172, 26, 0, 3}, {172, 26, 0, 2}]}}
```

```
{:ok, {:hostent, 'web', [], :inet, 4, [ip1, ip2] }} = :inet.gethostbyname(:web)
```

As expected, for the 'web' hostname the DNS provides two different IPs, 172.26.0.3 and 172.26.0.2, corresponding to the two nodes we launched previously.

### Autodiscovery nodes at startup

Some steps are needed to autodiscover the nodes based on the alias. First, we need to adapt the application code to:

1. Retrieve IPs of the nodes based on the `--net-alias`.
2. Get the hostname for each of the given IPs.
3. Use the retrieved hosts as parameters when starting Libcluster, to get them connected.

<div class="d-flex flex-row justify-content-center">
	<img style="max-width: 70%" src="/images/nodes_autodiscovery.png" alt="Start step for nodes autodiscovery">
</div>

With this in mind, the application's `Application.start()` should look like this:

``` Elixir
defmodule LibclusterPoc do
  use Application

  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: get_cluster_hosts()
        ]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: :cluster_supervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LibclusterPoc)
  end
```

The important piece of code is the function `get_cluster_hosts()`, which is in charge of asking the DNS for all the available nodes with that alias.

``` Elixir
  def get_cluster_hosts() do
    case :inet.gethostbyname(:web) do
      {:ok, {:hostent, 'web', [], :inet, 4, hosts_ip}} ->
        Enum.map(hosts_ip, fn ip ->
          {:ok, {:hostent, hostname, [], :inet, 4, _ips}} = :inet.gethostbyaddr(ip)

          String.to_atom("node@" <> normalize_hostname(hostname))
        end)

      error ->
        raise "Unexpected #{inspect(error)}"
    end
  end
```

Another auxiliary function, `normalize_hostname`, has been added because, when retrieving the hostname of some containers, the hostname contains the `--net-alias` as part of it. This can confuse Libcluster, so it needed to be removed.

```elixir
# Node2
  def normalize_hostname(hostname) do
    hostname
    |> to_string()
    |> String.split(".net_poc")
    |> List.first()
  end
end
```

Once we have modified the code, we need to rebuild the Docker image:

```bash
docker build -t libcluster .
```

Let's launch the first node:
```elixir
$ NODE=node1; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
iex(node@node1)1> Node.list)()
[]
```

```elixir
Let's launch the second one:
$ NODE=node2; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)

22:22:51.408 [info]  [libcluster:example] connected to :node@node2
iex(node@node1)1> Node.list)()
[:node@node1]
```

And the third one:

```elixir
$ NODE=node3; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help).

22:22:51.408 [info]  [libcluster:example] connected to :node@node1
22:22:51.408 [info]  [libcluster:example] connected to :node@node2
iex(node@node3)1> Node.list)()
[:node@node1, :node@node2]
```

We can see how each new host is automatically connected to the others.

# Final thoughts
This post has shown an interesting approach to autodiscovering nodes, but in each scenario we should analyze which option is best. For example, if we were working with Kubernetes, we could probably find another way to approach the problem using some built-in features. Libcluster offers a strategy related to [Kubernetes](https://github.com/bitwalker/libcluster/blob/master/lib/strategy/kubernetes.ex).
