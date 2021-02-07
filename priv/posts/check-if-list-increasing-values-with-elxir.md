---
author: "Juan Carlos Martinez de la Torre"
date: 2019-12-09
linktitle: check-a-list-is-increasing-in-elixir
menu:
  main:
    parent: tutorials
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title:  "[TIL] How to check that a list has increasing values in Elixir"
description: This tutorial will show you how to create a simple theme in Hugo.
weight: 10
---

I have been these days solving some of the problems of [advent of code](https://adventofcode.com/). These problems are a really nice way to sharp your skills with any programming language.  Although  my preferred language is still Elixir, I am trying to improve a little of my [Go](https://golang.org/) knowledge so I decided to give a try solving these problems. [Here](https://github.com/jkmrto/advent_of_code_2019) there are the solutions that I wrote.

By the way, I have been reading some of the solutions in Elixir and some of them have impressed since they have shown new ways to face the problems. I will write down some of these techniques (New at least for me)

**Traditional imperative paradigm**

In a traditional imperative C-type language like is Go we can solve this with a simple loop like this (the snippet can be executed [here](https://play.golang.org/p/f0e9lJIvti9)):

```Go
package main

import "fmt"

func isIncreasingList(list []int) bool {
    for i:=0 ; i < len(list) - 1; i++{
        if list[i] > list[i + 1] {
            return false
        }
    }
    return true
}

func main() {
    list := []int{1, 2, 3, 4, 5}
    fmt.Printf("%+v IsIncreasing?: %t", list, isIncreasingList(list))
}
```

**Functional Paradigm**

In a functional language like Elixir this check can be quite more complicated. At first glance for me, one idea that comes into me mind was to build a list of tuples where each tuple contains one element and the his adjunt like `[{i}, {i+1}]`. For example:

```Elixir
# Having this list:
list = [1,2,3,4,5]
# The objective list would be this:
objective_list = [{1,2}, {2,3}, {3,4}, {4,5}]
```

We can get the `objective_list` doing [this](https://repl.it/repls/MoralLateTab):

```Elixir
list = [1,2,3,4,5]
list1 = List.delete_at(list, length(list)-1)
list2 = List.delete_at(list, 0)
objective_list = Enum.zip(list1, list2)
> [{1, 2}, {2, 3}, {3, 4}, {4, 5}]
```

Once we have that list we can use [Enum.all/2()](https://hexdocs.pm/elixir/Enum.html#all?/2), to evaluate if any of the tuples doesn't fullfil the requirement:

```Elixir
list = [1,2,3,4,5]
List.delete_at(list, length(list)-1)
|> Enum.zip(List.delete_at(list, 0))
|> Enum.all?(fn {v1, v2} -> v2 > v1 end)
```

This could seem like an easy way to get the problem done. But it could be even simpler there is an utility called [Enum.chunk_every/4](https://hexdocs.pm/elixir/Enum.html#chunk_every/4) that can help us in the process on separate in slices our list

```Elixir
Enum.chunk_every([1,2,3,4,5], 2, 1, :discard)
> [[1, 2], [2, 3], [3, 4], [4, 5]]
```

Sorting everything up:

```
[1,2,3,4,5]
|> Enum.chunk_every(2, 1, :discard)
|> Enum.all?(fn {v1, v2} -> v2 > v1 end)
```

It is so amazing how some tedious problems in imperative languages can be solved in the functional paradigm. Maybe if we talk about performance probably the approximation of Go could be more efficient.