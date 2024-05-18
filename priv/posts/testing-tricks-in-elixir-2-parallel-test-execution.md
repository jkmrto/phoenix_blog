---
author: "Juan Carlos Martinez de la Torre"
date: 2024-03-01
linktitle: testing-tricks-in-elixir-2-parallel-test-execution
title: Testing in Elixir - Concurrent test execution 
intro: An objective of a great test suite is to reduce the executing time. The less time it requires, the shorter the feedback loop for developers. With this purpose, Elixir provides us some appraoches for test concurrent execution.  
toc: true
---

## Concurrent test execution

An objective of a great test suite is to reduce the executing time. The less time it requires, the shorter the feedback loop for developers. With this purpose, Elixir provides us some appraoches for test concurrent execution.

The common approach for building tests in Elixir is using the [ExUnit.Case](https://hexdocs.pm/ex_unit/1.13.4/ExUnit.Case.html) helper. One of the main characterisctis of this helper is that allows to executes concurrently the tests with `async: true`, It fosters parallelization and faster feedback loops. You can activate it by simply adding the attribute to the `use` statement:
```elixir
defmodule MyApp.Test do
  use ExUnit.Case, async: true
  ......
end
```

## Considerations with `async: true`

However, nuanced considerations come into play, and it's crucial to be aware of these possible issues:

### Limited concurrency within modules 

While `async: true` promotes concurrency, it's essential to note that tests within an individual module are still executed sequentially. This means that tests within the same file will run one after the other nevermind if `async` was set to `true` or `false`.

### Does your database support it? 

Elixir projects often integrate database operations into Unit tests. When utilizing `async: true`, be cautious of the fact that not all databases support concurrent transactional tests. For instance, MySQL poses challenges due to its transaction implementation, potentially leading to deadlocks. PostgreSQL is recommended in such scenarios, as it supports concurrent tests within the SQL sandbox. Elixir documenation clearly states this:

> While both postgresql and mysql support sql sandbox, only postgresql supports concurrent tests while running the sql sandbox. therefore, do not run concurrent tests with mysql as you may run into deadlocks due to its transaction implementation.

This consideration reinforces the preference for PostgreSQL in Phoenix projects.

### Challenges with Mox and Process Isolation

When using [Mox](https://github.com/dashbitco/mox) for mocking in Elixir tests, complexities may arise when processes other than the test process access mocks. By default, mocks are confined to the test process, which basically means that we have to rethink our strategy to keep our test concurrent in scenarios where different processess are involved.

One potential solution is the use of [explicit allowances](https://hexdocs.pm/mox/mox.html), allowing controlled access to mocks. However, in certain cases, identifying the process's PID, especially under supervision, might be challenging.

An alternative workaround is employing the [global mode](https://hexdocs.pm/mox/mox.html#module-global-mode), granting all processes access to the mock. Unfortunetely, this approach isn't compatible with the `async: true` option.

These considerations highlights the need for a thoughtful approach when adopting `async: true`. While it unlocks parallelization benefits, understanding its limitations ensures a smooth testing experience and avoids potential pitfalls in concurrent testing environments.


## Parallelizing the test suite with partitions

In addition to the option of running tests concurrently within different modules using `async: true`, other possibility for parallelizing test execution is to leverage multiple Elixir instances.

To achieve this, the [--partitions](https://hexdocs.pm/mix/1.12/Mix.Tasks.Test.html) argument on `mix test` comes into play, allowing us to specify the partition being executed using the `MIX_TEST_PARTITION` environment variable. Suppose we aim to distribute the tests across three different instances:


```bash
MIX_TEST_PARTITION=1 mix test --partitions 1
MIX_TEST_PARTITION=2 mix test --partitions 2
MIX_TEST_PARTITION=3 mix test --partitions 3
```

This alternative is specially interesting in cases where there are global resources that make not possible to use the `async: true` approach.

### Using mix `test --partitions` with MySQL

In the case of having a project that uses MySQL where it is not possible to use `async: true`, using this approach is a great way to improve the time that requires to run the test suite in the CI pipeline.

The main challenge related with this approach is that we need to provide a different database to each running Elixir instance. We can use the same MySQL server for that purpose, but initializing different databases through the Elixir configuration. 

At `config/runtime.test.exs` we can read this `MIX_TEST_PARTITION` environment variable, and we can inject this value into the database name.  

```elixir
db_suffix =
    case System.get_env("MIX_TEST_PARTITION") do
        "" -> ""
        partition -> "_#{partition}"
    end

# Configure your database
config :your_app, YourApp.Repo,
     database: "#{System.get_env("POSTGRES_DB", "your_app_test")}#{db_suffix}",
     ......
```

