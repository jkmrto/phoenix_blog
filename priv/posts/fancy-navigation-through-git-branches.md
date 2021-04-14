---
author: "Juan Carlos Martinez de la Torre"
date: 2021-04-14
title: Fancy navigation through git branches
intro: An easy way to navigate through git branches using fzf.

weight: 10
---

Navigate through git branches is something any deverlope do several times when working in a project. This can get quite annoying since it is necessary to remember the name of the branch to move to.

A simple but effective approach to make this process easier is using  [fzf](https://github.com/junegunn/fzf). This tool allows to select one element of a list of them, allowing to filter over the list interactively:

```elixir
$ git checkout $(git branch -a | fzf)
```

![Alt Text](../images/fancy-branches-navigator.gif)
