---
author: "Juan Carlos Martinez de la Torre"
date: 2024-04-01
linktitle: testing-tricks-in-elixir-3-setup-customization
title: Testing in Elixir - Setup customization
intro: A brief discussion of different options for test setup in Elixir and how to customize them using context @tags.
toc: true
test-series: true
---


## Setup blocks 

It is important to keep the tests as **concise** as possible, which means that we should avoid any boilerplate code that doesn't really add value to understanding the context of the test. The more concise a test is, the easier it is to focus our attention on the really informative part of the test.

Following this idea of reducing boilerplate, [ExUnit](https://hexdocs.pm/ex_unit/1.12.3/ExUnit.html) provides different setup blocks that are executed at the beginning of the tests, allowing us to share some initialization between tests and reduce the cognitive load when understanding the body of a test.

Let's say we need to create one `user` in all our tests and we want to avoid including the creation of a `company` for that `user`, since it doesn't add interesting information for understanding the test. We can use the [setup](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#setup/1) callback for it:

```elixir
defmodule AssertionTest do
  use ExUnit.Case, async: true

  # "setup" is called before each test, on the same test process
  setup do
    company = create_company()
    [user: create_user(company: company)]
  end

  test "test1", _context = %{user: _user} do
    assert true
  end

  test "test2", _context = %{user: _user} do
    assert true
  end
end
```

It is worth noting that this `setup` will be executed once per test. The keyword list returned by the setup block will be accessible in each test as a map, commonly known as the test `context`.

When using `describe` blocks, it is possible to have a different setup block per `describe` block:

```elixir
defmodule AssertionTest do
  use ExUnit.Case, async: true

    describe "func1/0" do
        setup do
            [user: create_user()]
        end
      .......
    end

    describe "func2/0" do
        setup do
            [company: create_company(:company)]
        end
        .......
    end
  end
```

## Other setup block alternatives

In my experience, this basic `setup` block per describe block or per file is the most common way of defining shared boilerplate in Elixir tests. However, ExUnit provides more options for sharing common setup code between tests. 

### Use setup_all/1

The [setup_all/1](https://hexdocs.pm/ex_unit/1.12.3/ExUnit.Callbacks.html#setup_all/1) callbacks are invoked only once per module, before any test is run. In contrast to `setup/1` blocks, `setup_all/1` is executed in a different process than the one executing the test.


```elixir
setup_all do
  [conn: Plug.Conn.build_conn()]
end
```

###  Pipeline of `setup` functions

It is possible to call the `setup` macro several times with different functions, for example:

```elixir
defmodule Test do
    use ExUnit.Case, async: true
    setup build_connection()
    setup build_user()

    defp build_connection(), do: [conn: Plug.Conn.build_conn()] 
    defp create_company(), do: [company: insert(:company)] 

    test "my test", _context = %{conn: conn, company: company} do
        ....
    end
end
```

We will end up with a `setup` context where the `context` returned in each one of the functions is merged. This allows us to create a kind of composable setup, depending on the functions that are called. However, it may not be very maintainable in the long term, since it could make it difficult to identify where each element was set up.

In any case, **it is preferable to keep the setup of the tests simple and easy to follow. Ideally just using the `setup` block**. When we start adding too many places where the setup happens, it becomes much harder to follow the whole test flow, which can be quite frustrating for developers.


## Setup customization - Context `@tags` 

In some scenarios we may want to use a setup block, but we would also like to customize some of the parameters of the setup. 

Let's imagine we have a function called `list_papers/2`, where the papers that are readable by each user depend on the role of the user and other query parameters. In Elixir, it is recommended to use a `describe` block to group all the tests related to the same function. We could have a test suite like this: 


```elixir
describe "list_papers/2" do
    test "an admin user can see all papers" do
        user = create_user(role: :admin)
        # test body
    end

    test "a regular user can see published papers" do
        user = create_user(role: :regular)
        # test body
    end

    test "a regular user can see draft papers wrote by him" do
        user = create_user(role: :regular)
        # test body
    end
end
```

We can see how the initialization of the users is quite repetitive. We could think about creating a `setup` block for sharing this initial setup, but we would need to customize the `role` for each user depending on the test. For that purpose, we can use the `@tag` property:


```elixir
describe "list_papers/2" do
    setup context do
        user_role = Map.get(context, :role, :regular)
        {:ok, user: create_user(role: user_role)}
    end

    @tag role: :admin
    test "an admin user can see all papers", %{user: user} do
        # test body
    end

    @tag role: :regular
    test "a regular user can see public papers", %{user: user} do
        # test body
    end

    @tag role: :regular
    test "a regular user can see draft papers wrote by him", %{user: user} do
        # test body
    end
end
```

This is just a very simple case where the `@tag` attribute is applicable. It would also be perfectly fine to keep the `create_user()` call in each individual test, since there is not a lot of overhead handled in the setup block. Normally, `@tag` makes more sense when there is a "heavy" setup block that needs to be customized in one of its first statements. 

By using setup callbacks and the `@tag` attribute, you can customize your test setup in Elixir to handle various testing scenarios efficiently. Custom tags allow for flexible test organization and execution, making ExUnit a powerful tool for testing in Elixir.
