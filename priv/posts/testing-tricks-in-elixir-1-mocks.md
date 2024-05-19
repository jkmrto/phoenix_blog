---
author: "Juan Carlos Martinez de la Torre"
date: 2024-02-01
linktitle: testing-tricks-in-elixir-1-mocks
title: Testing in Elixir - Mocks
intro: Mocks are an essential part of testing when building systems that need to communicate with external applications. At this post we discuss about recommended approach for using Mocks with Elixir, and what are the patterns that should be avoided.
toc: false
test-series: true
---

## Mocks in Elixir

One common pattern in testing is replacing a dependency by a custom piece of code, that may allow to simplify the testing approach. This replacement is commonly known as "Mock", although there are other definitions like "Stubs" or "Fakes" depending on the characteristics of the implementation that is replacing the dependency. 

Normally, when we talk about mocks we think about a 3rd API that inevitably needs to replaced, since we want to guarantee an stable test suite that doesn't depend on an external system in order to be green. That is a clear example where using mocks is legit, though there are other usages that are not so clear and that are prone to discussion.

In Elixir it is quite usual having unit tests that includes the interaction with the database as part of the tests. There are some drawback on this approach, since we are making our test inherently more slow, and also more coupled to a database which is not ideal. In some Software designs models like [Hexagonal Arquitecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)) the databases are treated as external dependencies, which means that is modeled as a port, and ports are normally replaced by mocks on Unit tests.

### State tests vs interaction tests with mocks  

One concept that really changed my mind about the usage of mocks is the idea of **prioritizing state tests over interaction ones**. With state-based testing, the function objective of the test is being evaluated through the value that is returned, if it is a pure function, or by the change that the function provokes, for example, in a database.

On the other hand, interaction testing validates how the downstream modules or functions are called, for example, checking if we are using the correct arguments on the dependency being called or checking the number of calls done to them. Normally, this kind of test makes use of mocks, which replace the dependency, allowing us to check what arguments were used.

The usage of **interaction tests provokes a coupling between the function being tested and the modules that are replaced using mocks**, since now when the interface of the downstream module is modified, the mock will also have to be modified, leading us to some brittleness. Brittleness is something to avoid in testing, since the more of it, the more maintenance those tests will require.

**In contrast, applying a testing approach based on state helps avoid potential fragility resulting from changes in downstream interfaces**. By solely focusing on the outcomes of the function under test, this approach mitigates the impact of alterations in the dependencies' interactions, contributing to increased test stability.

### Mox library

There is a well known article about mocks in Elixir, that was shared with the community around 2015. Titled as ["Mocks and explicit contracts"](https://dashbit.co/blog/mocks-and-explicit-contracts). the main purpose of this article was to provide some guidelines for Elixir developers about when to use Mocks.

In summary, it highlights the importance of only applying mocks over modules that implements a [Behaviour](https://hexdocs.pm/elixir/typespecs.html#behaviours). A Behaviour in Elixir allows to define interfaces, so that any module that tries to implement that Behaviour will have to implement that specified functions. 

Some years later, a library was introduced based on the guidelines of this article. This library is [Mox](https://github.com/dashbitco/mox), that is now the default library for creating mocks in Elixir. This library is based on the idea of defining explicit interfaces through Behaviors. It is quite easy to use this libary reading its [Documentation](https://github.com/dashbitco/mox).


### Final comments about mocks

What I find really interesing is that all the concepts explained above leads us to avoid the usage of Mocks as much as possible, maybe because we prefer the stability that states based testing provides us or because there is not a clear boundary that requires a Behaviour (interface) for introducing a mock using Mox. 

In any case, we have to think about alternatives before using a mock. Maybe we can cover the funcitonality being tested with a different approach. If not possible, it is good to have tools as Mox that allows to inject Mocks, though also forcing us to make a proper use of them.

