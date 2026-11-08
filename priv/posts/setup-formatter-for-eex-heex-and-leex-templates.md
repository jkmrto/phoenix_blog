---
author: "Juan Carlos Martinez de la Torre"
date: 2021-12-28
title: Set up formatters for eex and heex Elixir templates
intro: An overview of how to set up formatters for Elixir HTML templates.
toc: true

---

## Introduction

I like using formatters. They avoid unproductive discussions, allowing a team to focus on what really matters. Also, it is great when you have just written some messy code, with no proper indentation, and you see how everything looks much nicer right after applying the proper formatter.

When starting with `HTML` templates in Elixir, I tried to find a way to make a formatter work for `eex/leex`, which was possible with [prettier](https://prettier.io/) and [prettier-plugin-eex](https://www.npmjs.com/package/prettier-plugin-eex).

Lately, with the new `heex` templates in [LiveView 0.16](https://www.phoenixframework.org/blog/phoenix-1.6-released), this formatter started to fail, which was quite annoying. It looks like there is no predefined or ideal formatter for this kind of file.

## Setup prettier for eex/leex templates 

For `eex` and `leex` templates, [Prettier](https://prettier.io/) does a great job. Prettier is a well-known formatter, focused on JavaScript files, that also supports HTML ones. It takes care of indentation but can also parse the elements in each HTML block, which is great for fixing formatting issues inside each HTML tag. 

For some reason, the latest version of prettier generates some block errors. This issue is discussed in this thread: https://github.com/adamzapasnik/prettier-plugin-eex/issues/59. So, for compatibility, I use version 2.2.1.

Install prettier with version `v2.2.1`:

```bash
$ npm install -g prettier@2.2.1
```

Install the plugin for Elixir templates:

```bash
$ npm install -g prettier prettier-plugin-eex
```

Now we can apply this formatter to any file with: 

```bash
$ prettier my-template.html.eex
```

## Setup htmlbeautifier for `heex` files.

For `heex` templates, prettier is not the best approach. As a workaround, [htmlbeautifier](https://github.com/threedaymonk/htmlbeautifier) is proposed by several members of the Elixir community. As far as I have tested, it does the job. The main difference with prettier is that it doesn't parse anything inside each HTML tag, so it doesn't apply any formatting there. However, it automates the indentation of HTML elements, which is a great help. 

To set up this formatter, we need Ruby installed, since it is a Ruby gem. In my case, I use [asdf](https://github.com/asdf-vm/asdf) for it: 

Install Ruby with asdf:

```bash
$ asdf plugin-add ruby
$ asdf install ruby 3.0.0-dev
$ asdf global ruby 3.0.0-dev
```

Install the gem:

```bash
$ gem install html beautifier
```

Apply this formatter to a heex template:


```bash
$ htmlbeautifier admin.html.heex
```

## Formatting with Vim

My preferred way of formatting these files is manually, with a key binding. For example, by adding these lines to the `.vim` config, we will be able to trigger the formatter:

```vim
function FormatHeex()
	execute("!htmlbeautifier %")
endfunction

function FormatEex()
	execute("%!prettier --stdin-filepath %")
endfunction

au FileType eelixir nnoremap <leader>fp :silent call FormatEex() <CR>

au FileType eelixir nnoremap <leader>fh :silent call FormatHeex() <CR>
```

In my case, I use `<space>` as the leader key, so I trigger the formatter by pressing `<space>fp` for `eex/leex` files and `<space>fh`  for `heex` files.
