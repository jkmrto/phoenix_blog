---
author: "Juan Carlos Martinez de la Torre"
date: 2019-12-09
linktitle: check-a-list-is-increasing-in-elixir
title:  [TIL] How to check that a list has increasing values in Elixir
intro: These days I have been solving some of the [Advent of Code](https://adventofcode.com/) problems. They are a really nice way to sharpen your skills in any programming language. Although my preferred language is still Elixir, I am trying to improve my [Go](https://golang.org/) knowledge, so I decided to try solving these problems with it. [Here](https://github.com/jkmrto/advent_of_code_2019) are the solutions I wrote.
toc: false

---

These days I have been solving some of the [Advent of Code](https://adventofcode.com/) problems. They are a really nice way to sharpen your skills in any programming language. Although my preferred language is still Elixir, I am trying to improve my [Go](https://golang.org/) knowledge, so I decided to try solving these problems with it. [Here](https://github.com/jkmrto/advent_of_code_2019) are the solutions I wrote.

By the way, I have been reading some of the Elixir solutions, and some of them impressed me, since they showed new ways to approach the problems. I will write down some of these techniques (new, at least for me).

**Traditional imperative paradigm**

In a traditional imperative C-like language such as Go, we can solve this with a simple loop like this (the snippet can be executed [here](https://play.golang.org/p/f0e9lJIvti9)):

```go
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

In a functional language like Elixir, this check can be a bit more complicated. At first glance, the idea that came to my mind was to build a list of tuples where each tuple contains one element and its neighbor, like `[{i}, {i+1}]`. For example:

```elixir
# Having this list:
list = [1,2,3,4,5]
# The objective list would be this:
objective_list = [{1,2}, {2,3}, {3,4}, {4,5}]
```

We can get the `objective_list` by doing [this](https://repl.it/repls/MoralLateTab):

```elixir
list = [1,2,3,4,5]
list1 = List.delete_at(list, length(list)-1)
list2 = List.delete_at(list, 0)
objective_list = Enum.zip(list1, list2)
> [{1, 2}, {2, 3}, {3, 4}, {4, 5}]
```

Once we have that list, we can use [Enum.all/2()](https://hexdocs.pm/elixir/Enum.html#all?/2) to check whether all the tuples fulfill the requirement:

```elixir
list = [1,2,3,4,5]
List.delete_at(list, length(list)-1)
|> Enum.zip(List.delete_at(list, 0))
|> Enum.all?(fn {v1, v2} -> v2 > v1 end)
```

This could seem like an easy way to solve the problem, but it can be even simpler: there is a utility called [Enum.chunk_every/4](https://hexdocs.pm/elixir/Enum.html#chunk_every/4) that helps us split our list into slices:

```elixir
Enum.chunk_every([1,2,3,4,5], 2, 1, :discard)
[[1, 2], [2, 3], [3, 4], [4, 5]]
```

Putting everything together:

```elixir
[1,2,3,4,5]
|> Enum.chunk_every(2, 1, :discard)
|> Enum.all?(fn [v1, v2] -> v2 > v1 end)
```

It is amazing how some problems that are tedious in imperative languages can be solved in the functional paradigm. In terms of performance, though, the Go approach is probably more efficient.
