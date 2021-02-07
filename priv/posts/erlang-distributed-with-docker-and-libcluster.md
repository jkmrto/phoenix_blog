---
author: "Juan Carlos Martinez de la Torre"
date: 2019-09-11
linktitle: erlang-distributed-with-docker-and-libcluster
title: Erlang distributed with docker and libcluster.
weight: 10
intro: Last days I have been diving a little into the wonderful world of Erlang distributed. Elixir, has some built-in constructs for distributed systems which makes easier to distribute systems in comparison with other programming paradigms.

---

# Motivation

Last days I have been diving a little into the wonderful world of Erlang distributed. Elixir, has some built-in constructs for distributed systems which makes easier to distribute systems in comparison with other programming paradigms.

Since Erlang is based on the actor model (where each actor is a process) it is transparent to Erlang if the actor is local or if it is in a remote host, as long as the nodes are connected.

Another tool I love to user is Docker, so I started to dive into how to connect two Elixir instances dockerized, it has some tricks that we will discover along this posts.

# Connecting dockers with --net=host

In this first attempt we are going to launch two dockers using the latest elixir image, we will have opened two `iex` terminals where we can play with the nodes.

```bash
$ docker run -i -t --net=host elixir iex --sname node1 --cookie cookie
```
And our second node:
```bash
$ docker run -i -t --net=host elixir iex --sname node2 --cookie cookie
```

 At using [--net=host](https://docs.docker.com/network/host/) option we are making using of the same network interface between the two dockers, so at some point this scenario is quite similar to the one we have if we launch the two elixir instances locally.

Let's check if our two nodes are connected:

```lang-elixir
# Node2
> Node.list()
[]
```
This means that the nodes are not connected yet. It is needed to require to get the connection:

```Elixir
Node2
> Node.connect([:"node1@jkmrto-XPS-15-9570"])
true
```

Now our nodes are connected, we can check it:

```Elixir
iex(node2@jkmrto-XPS-15-9570)4> Node.list()
[:"node1@jkmrto-XPS-15-9570"]
```

Another way to check the connectivity with other node is using [:net_admin:ping()](http://Erlang.org/doc/man/net_adm.html#ping-1):

```elixir
# Node1
> :net_adm.ping(:node1@jkmrto-XPS-15-9570)
Pong

> Node.list()
[:"node1@jkmrto-XPS-15-9570"]
```

# Connecting nodes with Libcluster

One useful library when trying to get connected our nodes is [libcluster](https://github.com/bitwalker/libcluster). As his own documentation exposes:

> `This library provides a mechanism for automatically forming clusters of Erlang nodes`.

## Libcluster POC

Let's build a simple proof of concept with libcluster to run some test over it.

- Create the project:


```Bash
mix new libcluster_poc
```

Let's add the dependency on the mix file, remember to check the latest version at [hex](https://hex.pm/packages/libcluster)

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

Let's add the module that is called at entry point:

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
	- The strategic used by Libcluster is `Cluster.Strategy.Epmd` which relies on Epmd to get connected the different hosts.
	- They have been specified three nodes to get connected.

## Executing three instances locally

Let's launch the three instances in local and to check how the nodes are automatically connected.


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

Amazing! We can see how after running the third node the logs of this node indicates us that they have been correctly connected. So in the end, all we have to care about to get connected the nodes is to indicates the list of nodes when starting the application.


## Checking the Epmd

One interesting system of the Erlang ecosystem is the Erlang Port Mapper Daemon, also know as [Epmd](http://Erlang.org/doc/man/epmd.html). This service is in charge to map each Erlang node to the port where it is listening for connections.

An Epmd server is started as soon as one Erlang node starts. If another Erlang node is launched in the same node then the relation `{port, node_name}` will be added to the already running epmd.


We can check the Erlang nodes running in our machine using the epmd service. The epmd executable is located in the same folder that `erl` binary.
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


# Connecting three instances dockerized

## Dockerizing the application

Let's use this simple dockerfile:

``` docker
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

## Using docker network

Once we have our docker defined, we need to start think about how to have some of them connected. Let's now use an internal docker net, avoiding using the `--net=host` trick.

Let's create the network, calling it `net_poc`:

```Elixir
docker network create net_poc
```

## Custom docker run

Let's run our docker instances. We are going to need some options in order to get the expected behavior.

These options are:

- `-it`: It is required to initialize an interactive session.

- `--net net_poc`: It is required to attach the docker to network previously created.

-  `--name`: This would be the name of the node used by the [docker DNS](https://docs.docker.com/v17.09/engine/userguide/networking/configure-dns/) to resolve the docker location inside our custom network. It is also the name given to the docker that allows to identify the container when executing `docker ps`.

- `--hostname`: This will be the hostname of the docker launched. It is used by Erlang to fully qualified the Erlang node.

-  `--entrypoint=iex libcluster_poc --cookie cookie --sname node1 -S mix`: This syntax allows to define the docker image to be executed and a custom entry point, since it is needed to be different for each container in order to customize the name of the Erlang node with the -sname flag.
    - `--entrypoint=iex`: Executable to be run when starting the docker.
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


Once both of them are launched we can check that there is connectivity between both of them:

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

Great! We have are two docker fully connected.

It is important to note that the nodes are not connected when starting them and they get connected when doing `Node.ping/1`. The next step is getting them connected at startup.

## Automatic connection with Libcluster

We just need to redefine the nodes at Libcluster topologies to get nodes automatically connected at start.

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

Let's rebuild the docker


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

Wonderful! Now our two nodes are connected at start up thanks to Libcluster.

# Connecting Dockers using DNS autodiscovery

Until now we have been forced to explicitly indicate which are the nodes that are going to be connected in the configuration of libcluster.

Let's think about a possible scenario where we don't know the number of docker that are going to be available in our imaginary cluster. In that case, we will have to think about a way to autodiscover the nodes of our cluster.

When working with docker and custom networks one useful command is this scenario is the `--net-alias` that sets a custom alias and can be assigned for as many dockers as we want.

This shared alias can be used to autodiscover all the available dockers that have been labeled with the alias.

## Checking DNS autodiscovery.

Let's launch two nodes with the same `--net-alias`, that would be `web`. We should be able to get the addresses for these nodes asking to the docker DNS.

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

Now we should be able to retrieve the directions for this two hosts launching a new docker connected to the same network and asking to the DNS for the `web` alias.

```Elixir
# Node 3
jkmrto:~ $ docker run -it --net net_poc elixir
> :inet.gethostbyname(:web)
{:ok, {:hostent, 'web', [], :inet, 4, [{172, 26, 0, 3}, {172, 26, 0, 2}]}}
```

```
{:ok, {:hostent, 'web', [], :inet, 4, [ip1, ip2] }} = :inet.gethostbyname(:web)
```

As we expected for the 'web' hostname the DNS provides us with two different IPs 172.26.0.3 and 172.26.0.2, related to the two nodes we have previously launched.

## Autodiscovery nodes at startup

Some steps are needed to be able to autodiscover the nodes based on the alias. Firstly we need to adapt the code of the application in order to:

1. Retrieve IPs of the nodes based on the `--net-alias`.
2. For all the given IPs: Get hostname based on IP.
3. Used retrieved hosts as parameter on the start of Libcluster to get them connected.

![Start step for nodes autodiscovery](nodes_autodiscovery.png)

With this in mind the `Application.start()` of the application should look like:

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

The important piece of code is the function `get_cluster_hosts()`, which is in charge on ask for all the available nodes with that alias to the DNS.

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

Another auxiliary function has been added `normalize_hostname` because when retrieving the hostname of some dockers this hostname contains the `--net-alias` as part of it. This can cause confusion on Libcluster so it was needed to remove it.

``` Elixir
  def normalize_hostname(hostname) do
    hostname
    |> to_string()
    |> String.split(".net_poc")
    |> List.first()
  end
end
```

Once we have modified the code, we need to rebuild the docker:

``` Bash
docker build -t libcluster .
```



Let's launch the first node:
``` Elixir
$ NODE=node1; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
iex(node@node1)1> Node.list)()
[]
```

Let's launch the second one:
```Elixir
$ NODE=node2; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)

22:22:51.408 [info]  [libcluster:example] connected to :node@node2
iex(node@node1)1> Node.list)()
[:node@node1]
```

And the third one:

``` elixir
$ NODE=node3; docker run -it --net net_poc --hostname $NODE --net-alias web --name $NODE --entrypoint=iex libcluster_poc --cookie cookie --sname node@$NODE -S mix
Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help).

22:22:51.408 [info]  [libcluster:example] connected to :node@node1
22:22:51.408 [info]  [libcluster:example] connected to :node@node2
iex(node@node3)1> Node.list)()
[:node@node1, :node@node2]
```

We can see how each new host is automatically connected to the others.

# Final thoughts
At this post an interesting approach to get autodiscovery nodes has been exposed but in each scenario we should analyze which could be the best option. For example, If we were working with Kubernetes probably we can find another way to approach the problem making use of some built-in features. Libcluster offers a strategy related to [Kubernetes](https://github.com/bitwalker/libcluster/blob/master/lib/strategy/kubernetes.ex).
