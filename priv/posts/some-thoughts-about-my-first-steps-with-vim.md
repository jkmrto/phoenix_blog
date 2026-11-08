---
author: "Juan Carlos Martinez de la Torre"
date: 2020-02-20
linktitle: some-thoughts-about-my-first-steps-with-vim
title: Some thoughts about my first steps with Vim
intro: One of the unexpected things I found when I started working at Derivco was that almost everyone on my team was using Vim. How could they do that, editing whole projects just using the terminal? It seemed like black magic to me.

---

## Motivation

One of the unexpected things I found when I started working at Derivco was that almost everyone on my team was using Vim. How could they do that, editing whole projects just using the terminal? It seemed like black magic to me.

Throughout this year, I avoided giving Vim a try, mainly because I felt I needed to improve other skills like Elixir, Ecto or, lately, Go, and using Vim daily would have made it even harder to get used to my new role.

Once I knew I was definitely leaving Derivco, I decided to give Vim a chance, since I was going to have a less stressful month.

## What I like about Vim

For me, the best part of using Vim is the *developer experience* itself. It is really pleasant to be able to move around and edit the whole project using just the keyboard. I find it fun, and it improves my ability to focus.

One thing I found really annoying in VS Code is switching from the editor to the terminal. It was possible to bind some keys to switch between them, but it was quite complicated to navigate through terminal windows when you had them split. In fact, at some point I started to use [tmux](https://github.com/tmux/tmux/wiki), which added even more unneeded complexity.

In Vim 8 and Neovim, you get this integration out of the box, and it works really smoothly, making using Vim a great experience.

## Why Neovim instead of Vim 8.

Well, there is no strong reason for this. I started with Vim 8, but at some point I had some problems with the terminal, probably because I was just starting, but... I decided to give Neovim a try and it made everything easier, so why not continue with it?

In fact, some of my workmates were already using Neovim, so it was easier to get some tips from them ;)

## Useful Features and Plugins

Let's list some of the features and plugins that I find useful.

### Neovim-remote

Something you want to avoid is opening a new Vim (in my case, Neovim) instance inside your current Vim instance. But how do you avoid it when you are inside a terminal session handled by a Vim buffer? For me, that is the main use of this plugin, [neovim-remote](https://github.com/mhifnz/neovim-remote).

As explained in the plugin's README, when running `nvim`, a server is started for Neovim, and this plugin allows `nvr` to connect to that server instead of starting another instance.

### FZF

This plugin allows searching for files blazingly fast. I was used to VS Code and the `Ctrl + P` command to find and open a file, and the FZF plugin fulfills the same task.

The best part of discovering this plugin was learning that FZF can also be used on the command line to find files. Another nice feature is the possibility to override `Ctrl + r`, in my case by adding this to the `~/.zshrc` file:

```sh
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

Just a note: inside a Vim session, FZF uses the `:pwd` of your session as its root folder, so if you want to look for a file outside this path, you will need to change the `:pwd` using `:cd`.


### ALE Linter

The Asynchronous Lint Engine (ALE) allows running asynchronous analyses and linters in your Vim session. In fact, this capacity of async tasks is the main innovation in both Neovim and Vim 8.

Although the features it provides are already present in other IDEs, like VS Code, what I find interesting about ALE is that it gives you some control over how the binaries in charge of running the different analyses are called. For example, I had some trouble with the Go linter in VS Code (mainly due to Go modules), and I wasn't able to debug the problem. With ALE, however, whenever there is a problem you can use `:ALEInfo` to get some feedback about what is going on.

In the end, with Vim you need to do some configuration to get started with some plugins. That is nice if you run into problems, because at least you will know where to start looking, while in other IDEs almost everything is taken for granted, so you are quite blind when something goes wrong.
