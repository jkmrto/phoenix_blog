---
author: "Juan Carlos Martinez de la Torre"
date: 2019-09-11
linktitle: cloud-native-devops-with-kubernetes
title: Cloud native devops with kubernetes - Notes 
toc: true
---


<div class="my-5"></div>

## Handlig migrations

A tricky part of applications that depends on databases is how to handle migrations. Ideally, those migrations should be run before a new version of the application start running, so that the new schemas are already in the database when they are expected by the application. Two possible approaches:

- **Helm Hooks**. Helm hooks allows to control the order in which things happen in a deploy. For a DB migration we can use the `pre-upgrade` hook. It allows to schedules a Kubernetes Job just before an upgrade.
- **Init Containers** are containers that run to completion before the regular container in the pod start.

By default, Kubernetes applies a **Rolling Update** when deploying a new version. This means only one pod is upgraded at a time. This means that at a certain moment we may have different versions running at the same time which can lead to issues if the changes involve migration. We have to be extra careful on those cases. 


## Using preemptive instances to reduce costs 

These instances provide no availability guarantees but may be a good option to reduce costs. However, it is a good idea to at least limit the preemtible nodes to no more than two thirds of the cluster.


## Ensure cluster workload is balanced

In general the [Kubernetes scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) does a great job. However, there are some edge cases where the scheduler can be quite messy. The scheduler never moves one pod to other server unless they are restarted for some reason. In thoses cases, there is a tool called [Descheduler](https://github.com/kubernetes-sigs/descheduler) which aims to place the worload evenly across all the nodes in the cluster.

## [Quality of Service](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)

Based on the [resource limits and requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) of a Pod, Kubernetes will classify them in the following groups:
- **Guaranteed**: When request match limits are specified. These are the highest priority pods.
- **Burstable**: When request is below limit, the pod is able to take resources from the node if available. If not, the pod is "burst".
- **BestEffort**: When no request or limit are specified. These pods will be first being killed in case of a node running out of resources.

## Avoid the usage of the latest tag

The latest tag doesn't neccessarily identify the most recent image, just the most recent image that has not been explicitly tagged. It is important to always specify a tag when deploying to production. Ideally, we should use [container's digest](https://cloud.google.com/kubernetes-engine/docs/archive/using-container-images) for deterministic deployments. Images can have many digest, but only one digest. 



##  Security.
It is important to run containers with the minimum possible privileges.
- **Run containers as non-root users.** If a `runAsUser` is specified, it will override any user configured in the container. We must ensure that the user exists on the containter. On Linux systems, UID is assigned to the first non-root user created. 

```
containers:
 - name: demo
   image: demo:hello 
   securityContext: 
     runAsUser:1000
```

- **Blocking root containers** Kubernetes allows to block containers that want to run as root. This is is useful for third party containers that may be configured as root.

```
containers:
 - name: demo
   image: demo:hello 
   securityContext: 
     runAsNonRoot: true
```

- **Setting a Read-Only Filesystem.**. It is a good practice to always use `readOnlyFileSystem` unless the container needs to access the file system.

```
containers:
 - name: demo
   image: demo:hello 
   securityContext: 
     readOnlyFileSystem: true
```


- **Disable privilege escalation.** Binaries that use the `setuid` can temporarily gain privileges of the user that owns the binary. To prevent this, we have to use the [allowPrivilegeEscalation ](https://docs.bridgecrew.io/docs/bc_k8s_19) field:

```
containers:
 - name: demo
   image: demo:hello 
   securityContext: 
     allowPrivilegeEscalation: false
```

## Helm

Helm is a package manager for kubernetes. Those packages are called **Helm charts**. These **charts** use Yaml templates that define the resources needed for an application, and some placeholder for configuration. **We could say that a Helm Chart is just a convenient wrapper over Kubernetes Yaml manifests.**

- It allows to separate the raw manifest files from the particular settings and variables.
- It allows to create packages with the manifests, making easier to share them to other users.
- Normally, a `values.yaml` is used to specify the default configuration the variables defined in the template manifests

