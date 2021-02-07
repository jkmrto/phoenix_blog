---
author: "Juan Carlos Martinez de la Torre"
date: 2020-02-20
linktitle: some-thoughts-about-my-first-steps-with-vim
next: /tutorials/github-pages-blog
prev: /tutorials/automated-deployments
title: Some thougths about my firsts steps with VIM
description: Vim, first-steps
weight: 10
---

One of the unexpected things I found when I started to work at Derivco was that almost everyone in my team was using Vim. How can they do that? Edit all the projects just using the terminal. It seems like black magic to me.

Along this year I avoided to giving a try to Vim, mainly because I felt I needed to improve other skills like Elixir, Ecto or, lately, Golang and having to use VIM in a daily routine will make even harder get used to my new role.

After knowing I was definitely going to leave Derivco, I decided to give a chance to Vim, since I was going to have a less stressful month.

## What I like about Vim

For me the best part of using VIM is the *developer experience* itself. It is really pleasant for to be able to modify all along the project just using the keyboard. I find it funny and it improves my capacity to focus.

One thing that I found really annoying in VS code is changing from the editor to the terminal. It was possible to bind some keys to change between them but was quite complicated to navigate through terminals window when you have them splitted. In fact at some point I started to use [tmux](https://github.com/tmux/tmux/wiki) what add even more unneeded complexity.

In Vim 8 and NeoVim you have this integration totally for granted and it works really smothly, making a greak experience of using vim.

## Why Neovim instead of Vim 8.

Well, no hard reason for this. I started with Vim 8 but at some point I had some problems with the terminal, probably because I was just starting but... I decided to give a try to Neovim and it made easier everything so why not to continue with it?

In fact, some of my workmates were already using Neovim instead so it was easier to get some tips from them ;)

## Useful Features and Plugins

Let's list some of the features and Plugins that I find useful.

### Neovim-remote

Something you have to avoid is to open a new vim (in my case it is neovim) instance inside your current vim instance. But how to do this when you are inside a terminal session handled by a Vim buffer?. That is the main utility for me of this plugin. [neovim-remote](https://github.com/mhifnz/neovim-remote).

As it is explained at the Readme of this plugin, when running `nvim` a server is started for Neovim and what this plugin allows is that runnig `nvr` the Neovim instance will get connected to this server instead of running another one.

### FZF

This plugin allows searching files blazingly fast. Got used to VSCode and the `Ctrl + P` command to look for a file and open it, this FZF plugin fulfills the same task.

The best part of the meeting this plugin was discovering that FZF can be used in the command line to find files. Another nice utility is the possibility to overwrite the `Ctrl + r`, In my case adding to the `~/.zshrc` file:

```
# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/opt/fzf/shell/key-bindings.zsh"
```

Just a note: Inside a Vim session Fzf takes as root folder the `:pwd` of your session so if you want to look for a file out of this path you will need to change the `:pwd` using `:cd`.


### ALE Linter

This Asynchronous Lint Engine (ALE) allows running asynchronous analyses and linters on your VIM session. In fact, this capacity of async tasks is the main innovation in both Neovim and Vim 8.

Although the feature it provides is already present in other IDEs, like VS code, what I find interesting about using ALE is that it gives you some control about how you are calling the binaries that are in charge of running the different analyses. For example, I had some troubles with the linter of GO in VScode (mainly due to go modules functionalities) I wasn't able to debug which was the problem. However with ALE whenever there is a problem you can use `:ALEInfo` to get some feedback about what is going on.

At the end with Vim you need to make some configuration for getting started with some plugins which are nice if you have any problem with them because at least you will know where to start to look while in other IDEs you have almost everything for granted so you are quite blind if you have any problem.
