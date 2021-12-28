---
author: "Juan Carlos Martinez de la Torre"
date: 2021-04-14
title: Fancy navigation through git branches
intro: An easy way to navigate through git branches using fzf.
toc: false

---

Navigate through git branches is something any developer do several times when working in a project. This can be quite annoying since it is necessary to remember the name of the branch to move to.

## Long story short

A simple but effective approach to make this process easier is using this: `git checkout $(git branch -a | fzf)`.

![Alt Text](../images/fancy-branches-navigator.gif)

## Step by Step

1 - List the available branches with `git branch -a`. Only the local branches will be listed.
```console
$ git branch -a
```

2 - Select a branch from the list with `fzf`
```console
$ git branch -a | fzf
```

3 - Use the selected branch for the git checkout:
```console
$ git checkout (git branch -a | fzf)
```

4 - [Bonus] Integrate it at `zsh`. Appending this into `~/.zsh`
```console
alias gck="git checkout (git branch -a | fzf)"
```
