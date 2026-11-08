---
author: "Juan Carlos Martinez de la Torre"
date: 2024-01-01
linktitle: testing-tricks-in-elixir-0-intro
title: Testing in Elixir - The importance of testing
intro: An overview of the characteristics of effective tests that help with the maintainability and extensibility of a project in the long term.
toc: false
test-series: true
---

Lately I have been rethinking some of the practices and strategies I follow when writing tests in Elixir. I thought it would be a good idea to write about them in a series of quick posts.

In this first post, I’ll introduce some fundamental testing principles before diving into specific techniques and tricks that are particularly useful in Elixir.

## The importance of tests 

Automated testing serves as a robust defense against bugs seeping into the production environment, especially in projects with a long lifespan. As a project grows and accumulates contributors, coupled with ongoing refactors, maintaining stability becomes a challenge.

Ensuring the project's extensibility while preserving stability is particularly crucial. Well-designed tests act as a guarantee that a feature developed today will have the same behavior even after subsequent refactors or the addition of new features.
 
## Key Characteristics of Effective Tests

To guarantee the effectiveness and maintainability of a test suite in the long term, it is valuable to define some characteristics that each test should have. One of the last books I read, [Software Engineering at Google](https://www.goodreads.com/en/book/show/48816586), provides some great insights about them:

- **Completeness**: A test is complete when the body contains all the information a reader needs to understand how it arrives at the result.
- **Conciseness**: A test should avoid containing any superfluous information that is irrelevant or even distracting. The less code surface a test has, the less likely it is to be affected by a change in another part of the codebase. 
- **Test State, not Behaviors**: Distinguishing between state testing and behavior testing is crucial. State testing evaluates changes a function has made, while behavior testing scrutinizes interactions with other components. Preferably, lean towards state changes to avoid unnecessary dependencies. 

The ultimate goal of these characteristics is to avoid brittle tests. Brittle tests are prone to failure due to unrelated changes, leading to a frustrating developer experience. 

From a test suite perspective, we want a stable test suite that runs as fast as possible. Exploring this idea, these are other characteristics to look for:

- **Quick execution time**: The quicker a test suite is, the sooner a developer gets feedback from it. Reducing the feedback loop increases productivity in the long term. Another benefit is lower resource consumption in the CI, which may affect some bills.
- **Deterministic**: A test is deterministic if running it several times always produces the same outcome. This may look simple, but some cases need extra effort, like working with dates or handling possible race conditions in asynchronous processes.
