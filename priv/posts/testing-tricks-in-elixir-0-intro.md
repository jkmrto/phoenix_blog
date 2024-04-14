---
author: "Juan Carlos Martinez de la Torre"
date: 2024-01-01
linktitle: testing-tricks-in-elixir-0-intro
title: Testing tricks in Elixir - The importance of testing
intro: Overview about the characteristics of effective tests that will help with the maintenability and the extensibility of a project in the long term.
# toc: true
---

## The Significance of Tests

Automated testing serves as a robust defense against bugs seeping into the production environment, especially in projects with a long lifespan. As a project grows and accumulates contributors, coupled with ongoing refactors, maintaining stability becomes a challenge.

Ensuring the project's extensibility while preserving stability is particularly crucial. Well-designed tests act as a guarantee that a feature developed today will have the same behavior even after subsequent refactors or the addition of new features.
 
## Key Characteristics of Effective Tests

In order to guarantee the effectivity and the maintenability of a test suite in the long term, it is valuable to define some characteristics that each test should have. One of the last book I read, [Software Engineering at Google](https://www.goodreads.com/en/book/show/48816586), provides some great insights about them:

- **Completeness**: A test is complete when the body contains all the information a reader needs to understand how it arrives to the result.
- **Conciseness**: A test should avoid contaning any superflous information that it is irrelevant or even distracting. The less code surface we have in a test, the less probable is that it may be affected by a change in other part of the codebase. 
- **Test State not Behaviours**: Distinguishing between state testing and behavior testing is crucial. State testing evaluates changes a function has made, while behavior testing scrutinizes interactions with other components. Preferably, lean towards state changes to avoid unnecessary dependencies. 

The ultimate goal of these characteristics is to avoid brittle tests. Brittle tests are prone to failure due to unrelated changes, leading to a frustrating developer experience. 

If we take a wider perspective, from a test suite point of view some other characteristics that are also worthy to look for on each individual test since are:

- **Quick execution time** The quicker a test suite is, the quicker a developer will get feedback from it. Reducing the time of the feedback loop will increase the productivity in the long term.
- **Deterministic**. A test is deterministic if running it always generates the same outcome. This may look simple but there are some cases that needs an extra effort like when working with dates, since we need to ensure that the pass of time won't affect the outcome of the test.

Along the next posts I will exposes some ideas and tricks when testing with Elixir that faciliates to follow the characteristics mentioned above. 











