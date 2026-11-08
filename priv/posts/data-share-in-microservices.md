---
author: "Juan Carlos Martinez de la Torre"
date: 2021-06-20
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title: An overview of data sharing in microservices
intro: Microservices aim for independence, which requires data isolation. To provide it, we must adopt an effective approach for sharing data among services. Two approaches are possible, using synchronous requests or asynchronous events for data distribution.

weight: 10
---

<hr style="visibility:hidden; margin:0" />

*This post is an attempt to explain some concepts about microservices and data sharing that I have been learning recently. The main aim is to summarize them, not to go deep into the details*.


## Sharing data is a key concept in microservices

Microservices are designed for independence and autonomy. This involves each service being able to be developed and deployed separately, with the idea of parallelizing each stage as much as possible.

Each service is in charge of some business functionalities. These responsibilities define the scope and the data that will be required to fulfil them. Based on this scope, each service will be the owner of a part of the whole data ecosystem.

To provide as much independence as possible, each microservice should have its own data storage, which usually means having a different database. But microservices are not data silos, they need to share information to complete those functionalities. This is why the approach of how to share data is so important.


## Sharing data: Synchronous requests

Since all microservices will need to share information at some point, we need to think about the best approach. The simplest one is using synchronous requests between services, so whenever a service needs information stored in other systems, it must be able to fetch it using, for example, a REST API.

<br>
<img class="center" src="/images/request-response.png" />
<br>

It sounds simple, but there are some concerns to take into account:

**1** - **What happens if the system that should answer the synchronous request is down?** This creates a dependency between services, since the client service won't be able to continue until its request is answered. This is a red flag for microservices design since it violates the independence principle.

**2** - Let's imagine a client service that needs to fetch the same data several times. We may think that we are overloading the other service with requests, so **it may make sense to use some kind of cache to be able to load the information without having to call the other system so many times**. The main problem with this kind of cache approach is that we don't know whether the data in the cache is the latest version. This is commonly known as stale data.

**3** - Another consideration is the scalability of the approach. **The more services we have in the system, the more cross-service requests will be made**. So we should consider that this approach will penalize our environment in the long term.

The level of resilience of each microservice is determined by its level of autonomy, which is drastically reduced if it has to ask for any information from other services at any time.

## Sharing data: Event driven approach

**What if, instead of having to ask another microservice, the client service had already stored the required information in its database?**

In this approach, each service publishes a message whenever something is modified in its data context. The interested consumers receive these updates as soon as they happen, storing the useful information in their database. Now the service can fetch the information from its own data storage, instead of having to synchronously ask other services, removing any temporal coupling.

<br>
<img class="center" class="blog-img" src="/images/simple-pub-sub.png" />
<br>

Normally those messages are known as events. We can reason about an event as an immutable record that is self-contained and that represents an action that has been done at some point in the past.

We can summarize this approach as:

**1** -  In a microservices environment, each service is the owner of a limited part of the data, this defines the context of each service.

**2** - Each data owner will publish an event/message whenever a create/update/delete happens in any of the entities/objects that are part of its context.

**3** - The event is published to an event log system, like Kafka. This system will be in charge of guaranteeing that the message is consumed at least once in each interested microservice.

**4** - The services interested in the event process the change, applying any required modification in its data context.

**5** - Normally, not all the published information is required by the consumers, so they process it and build new objects/entities, part of the consumer context, with just the information they need.

### Event log

It is possible to send messages directly from one service to another, but normally an event log is used as an intermediate system. The event log is in charge of receiving the events from the producers and pushing the messages to the interested consumers. The main benefits are:


**1** - **Logical decoupling**. Adding more consumers is transparent to the producers, since they don't know about consumers; they just know about the event log where they have to publish the events.

**2** - **Temporal decoupling**. Consumers and producers are asynchronous, since producers just need to publish to the event log; they don't care when the messages will be consumed.

**3** - **At least once delivery guarantees**. The event log ensures that each message is processed by the interested consumers at least once. Since a client can crash at any time, the event log usually implements an *acknowledgement* mechanism followed by the consumers: they have to explicitly acknowledge to the event log when they have finished processing an event.

<br>
<img class="center" style="width: 70%" class="blog-img" src="/images/event-log-pub-sub.png" />
<br>


If a consumer finishes consuming an event but crashes just before sending the *ack* to the event log, the event will be resent to the consumer as soon as it is up again. This can cause an event to be consumed more than once. The ability to apply the same action several times, always producing the same effect as if it were applied only once, is known as **idempotency**.

Idempotency is a critical feature in cloud-native applications, since there is a lot of network communication among services, and a service may fail to *ack* an action even though it has already applied it.


### Event log vs  Messages broker

Kafka is the best-known event log. It allows broadcasting events to various consumers, it persists the events for some time after they are delivered to the interested consumers, and it allows new consumers to replay old stored events.

There are other possible approaches, like using a message broker. RabbitMQ is an example of a message broker; the main difference is that it doesn't persist events after they are delivered to the consumer.

The main advantage of persisting events after they are consumed is that it enables replaying past events, allowing us to replicate the state of any service at any point in time. This is an ideal case, though, since the capacity to store events in an event log is not infinite, so at some point it must start deleting old events.


### Event driven architecture and domain driven design

The technique called **Event Sourcing**, part of domain-driven design (DDD), applies this idea of communicating services using events. Similarly, it involves saving all the events in an event log/store where the rest of the services can consume them.

Each event is an immutable fact already validated by the producer, which means the rest of the services are forced to consume it to avoid desynchronization.

In DDD, the scope of each service is known as the bounded context, which matches the idea of each service being the owner of a part of the data domain.

### Events driven architecture side effects

At first sight, using events to share data across services looks like an ideal approach, since it fits well with a microservice architecture, providing scalability, temporal decoupling and independence. However, we should take into account some complexities:

**1**. **State initialization and recovery**. When setting up a new service, we need to provide a way to initialize its data context.

Ideally, it would be possible to regenerate the derived data from the event log. If we need data that is not in the event log (maybe because the event log data has a TimeToLive configuration), the producer system must provide a way to send this information to the consumer.

An important detail is that any consumer service is resilient to temporary downtime, since the events are persisted in the event store until they are consumed.

**2** -  **Replication lag and eventual consistency**. One downside is that event consumers are asynchronous, so a user may read from a service that doesn't have the latest version of the data, getting a stale version of the information.

This idea is related to the consistency requirements of a system. Although some services may be in a stale state for some time, in the end, the system will converge to consistency, which is known as **eventual consistency**.

This concept is similar to **replication lag**, which is used in distributed databases when a replica is out of date because it has not yet received the latest update from the master database.

**3** - **Events ordering**. To have a consistent system we need to pay attention to the order in which the events are consumed by the client. Consuming events out of order may lead to an inconsistent state.

When possible, the simplest approach is to funnel all the events through one publisher and read them only from one consumer. This way we force all the events to be processed sequentially in the same order as they were published.

At some point, we may need to scale this approach since a single node may not fulfil the throughput requirements. In this case, we could start using different partitions to route the events.

Delivery order is guaranteed within a partition, but not across partitions. Related events must be sent to the same partition to preserve the causal relations between them.

## References

**-** [Designing Data-Intensive Applications, by Martin Kleppmann](https://www.amazon.es/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321)

**-** [Cloud native patterns, by Cornelia Davis](https://www.manning.com/books/cloud-native-patterns)

**-** [Monolith to microservices, by Sam Newman](https://www.amazon.es/Monolith-Microservices-Evolutionary-Patterns-Transform/dp/1492047848)
