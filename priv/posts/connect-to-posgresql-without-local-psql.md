---
author: "Juan Carlos Martinez de la Torre"
date: 2019-11-26
linktitle: connect-to-remote-postgresql-without-local-psql
menu:
  main:
    parent: tutorials
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title:  "[TIL] How to connect to a remote postgresql without local psql"
description: This tutorial will show you how to create a simple theme in Hugo.
weight: 10
---


This will open the **psql** terminal where execute our commands:

```Bash
docker run -it -e PGPASSWORD=postgres --net=host \
    --entrypoint=psql postgres:11                \
    -h localhost -p 5432 -U postgres
```

Using a docker can be useful for:

1. Avoiding having to install the psql-client locally

2. Ensuring the posgresql-client is in the same version as the database where we pretend to get connected.

We can indicate a command to be exeucted with `-c` option: 


```Bash
docker run -it -e PGPASSWORD=postgres --net=host \
    --entrypoint=psql postgres:11                \
    -h localhost -p 5432 -U postgres \
    -c 'SELECT pg_reload_conf();'
```
