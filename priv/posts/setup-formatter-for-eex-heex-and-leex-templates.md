---
author: "Juan Carlos Martinez de la Torre"
date: 2021-12-28
title: Setup formatter for eex and heex elixir templates  
intro: An overview about how to setup formatters for elixir HTML templates.  
toc: true

---

## Introduction

I like using formatters. It avoids unproductive discussions, allowing a team to focus on what really matters. Also, it is great when you just wrote some messy code, with no proper indentation, and you see how everything looks much nicer just after applying the proper formatter.

When starting with `HTML` templates in Elixir, I tried to find a way to make fomatter works for `eex/leex`, which was possible with [prettier](https://prettier.io/) and [prettier-plugin-eex](https://www.npmjs.com/package/prettier-plugin-eex).

Lately, with the new `heex` templates at [LiveView 0.16](https://www.phoenixframework.org/blog/phoenix-1.6-released) this formatted started to fail, which was quite disgusting. It looks like there is not a predefined or ideal formatter for this kind of files

## Setup prettier for eex/leex templates 

For `eex` and `leex` templates, [Prettier](https://prettier.io/) does a great job. Prettier is a well-known formatter, focused on Javascript files, but that also supporsts HTML ones. It takes care of indentation but also can parse the elements on each HTML block, which is great for fixing format issues internal on each HTML tag. 

For some reason, the latest version of prettier generates some block errors. In this forum thread https://github.com/adamzapasnik/prettier-plugin-eex/issues/59 this issue is commented on. So, for compatibility, I use the 2.2.1 version.

Install prettier with version `v2.2.1`:

```bash
$ npm install -g prettier@2.2.1
```

Install plugin for elixir templates:

```bash
$ npm install -g prettier prettier-plugin-eex
```

Now we can apply this formatter to any file with: 

```bash
$ prettier my-template.html.eex
```

## Setup htmlbeautifier for `heex` files.

For `heex` templates prettier is not the best approach. As workaround, [htmlbeautifier](https://github.com/threedaymonk/htmlbeautifier) is proposed by several members of the Elixir community. As far as I have tested, it does the work, main difference with prettier is that it doesn't parse anything inside each HTML tag, so it doesn't apply any proper format there. However, it automatizes the indentation for HTML elements, that is a nice great help. 

For setting up this formatter we need to have ruby installed, since this formatter is a Ruby gem. In my case, I use [asdf](https://github.com/asdf-vm/asdf) for it: 

Install Ruby with asdf

```bash
$ asdf plugin-add ruby
$ asdf install ruby 3.0.0-dev
$ asdf global ruby 3.0.0-dev
```

Install gem:

```bash
$ gem install html beautifier
```

Applying this formatter to a heex templates


```bash
$ htmlbeautifier admin.html.heex
```

## Formatting with Vim

My preferred way of handling formatting for these files is using a manual approach, pressing some key binding for it. For example, by adding these lines to the `.vim` config, we will be able to trigger the formatter:

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

In my case, I use `<space>` as leader key, so I trigger the formatter pressing `<space>fp` for `eex/leex` files and `<space>fh`  for `heex` files.
