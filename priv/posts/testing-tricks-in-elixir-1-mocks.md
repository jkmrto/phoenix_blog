---
author: "Juan Carlos Martinez de la Torre"
date: 2024-02-01
linktitle: testing-tricks-in-elixir-1-mocks
title: Testing in Elixir - Mocks
intro: Mocks are an essential part of testing when building systems that need to communicate with external applications. In this post, we discuss the recommended approach for using mocks in Elixir, and which patterns should be avoided.
toc: false
test-series: true
---

## Mocks in Elixir

One common pattern in testing is replacing a dependency with a custom piece of code, which can simplify the testing approach. This replacement is commonly known as a "mock", although there are other terms like "stubs" or "fakes", depending on the characteristics of the implementation that replaces the dependency. 

Normally, when we talk about mocks, we think about a third-party API that inevitably needs to be replaced, since we want to guarantee a stable test suite that doesn't depend on an external system to be green. That is a clear example where using mocks is legitimate, though there are other uses that are not so clear and are open to discussion.

In Elixir, it is quite common to have unit tests that include interaction with the database. There are some drawbacks to this approach, since it makes our tests inherently slower and more coupled to a database, which is not ideal. In some software design models like [Hexagonal Architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)), databases are treated as external dependencies, which means they are modeled as ports, and ports are normally replaced by mocks in unit tests.

### State tests vs interaction tests with mocks  

One concept that really changed my mind about the usage of mocks is the idea of **prioritizing state tests over interaction ones**. With state-based testing, the function under test is evaluated through the value it returns, if it is a pure function, or through the change it causes, for example, in a database.

On the other hand, interaction testing validates how the downstream modules or functions are called, for example, checking whether we are using the correct arguments when calling the dependency, or checking the number of calls made to it. Normally, this kind of test makes use of mocks, which replace the dependency, allowing us to check what arguments were used.

The use of **interaction tests creates coupling between the function being tested and the modules that are replaced using mocks**, since whenever the interface of the downstream module is modified, the mock will also have to be modified, leading to brittleness. Brittleness is something to avoid in testing, since the more of it there is, the more maintenance those tests will require.

**In contrast, applying a testing approach based on state helps avoid potential fragility resulting from changes in downstream interfaces**. By solely focusing on the outcomes of the function under test, this approach mitigates the impact of alterations in the dependencies' interactions, contributing to increased test stability.

### Mox library

There is a well-known article about mocks in Elixir that was shared with the community around 2015, titled ["Mocks and explicit contracts"](https://dashbit.co/blog/mocks-and-explicit-contracts). The main purpose of this article was to provide guidelines for Elixir developers about when to use mocks.

In summary, it highlights the importance of only applying mocks to modules that implement a [Behaviour](https://hexdocs.pm/elixir/typespecs.html#behaviours). A Behaviour in Elixir allows us to define interfaces, so that any module implementing that Behaviour has to implement the specified functions. 

Some years later, a library was introduced based on the guidelines of this article. This library is [Mox](https://github.com/dashbitco/mox), which is now the default library for creating mocks in Elixir. It is based on the idea of defining explicit interfaces through Behaviours. It is quite easy to use by following its [documentation](https://github.com/dashbitco/mox).


### Final comments about mocks

What I find really interesting is that all the concepts explained above lead us to avoid using mocks as much as possible, maybe because we prefer the stability that state-based testing provides, or because there is no clear boundary that requires a Behaviour (interface) for introducing a mock with Mox. 

In any case, we have to think about alternatives before using a mock. Maybe we can cover the functionality being tested with a different approach. If that is not possible, it is good to have tools like Mox that allow us to inject mocks, while also forcing us to use them properly.

