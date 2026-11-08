---
author: "Juan Carlos Martinez de la Torre"
date: 2019-11-26
linktitle: connect-to-remote-postgresql-without-local-psql
title:  [TIL] How to connect to a remote PostgreSQL without a local psql
intro: A simple way to connect to a PostgreSQL database without having to use a local psql client.
toc: false

---


This will open the **psql** terminal, where we can execute our commands:

```bash
docker run -it -e PGPASSWORD=postgres --net=host \
    --entrypoint=psql postgres:11                \
    -h localhost -p 5432 -U postgres
```

Using Docker can be useful for:

- Avoiding having to install the psql client locally.
- Ensuring the PostgreSQL client is the same version as the database we want to connect to.

We can pass a command to be executed with the `-c` option:


```bash
docker run -it -e PGPASSWORD=postgres --net=host \
    --entrypoint=psql postgres:11                \
    -h localhost -p 5432 -U postgres \
    -c 'SELECT pg_reload_conf();'
```
