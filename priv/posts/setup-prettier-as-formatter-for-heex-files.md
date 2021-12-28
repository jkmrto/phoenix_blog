---
author: "Juan Carlos Martinez de la Torre"
date: 2021-12-28
title: Setup prettier as formatter for heex files 
intro: How to setup prettier for heex files, the new html templates in elixir
toc: true

---

## Introduction 

When starting with `HTML` templates in Elixir, I tried to find a way to make fomatter works for `eex/leex`, which was possible with [prettier](https://prettier.io/) and [prettier-plugin-eex](https://www.npmjs.com/package/prettier-plugin-eex).

Lately, with the new `heex` templates at [LiveView 0.16](https://www.phoenixframework.org/blog/phoenix-1.6-released) my formatter started not to work, since it was a new type of file but the fix was quite easy at the end.

## Installing prettier and eex plugin

For some reason, latest version for prettier generates some block errors. In this thread: https://github.com/adamzapasnik/prettier-plugin-eex/issues/59, this issue is commented. 

Install prettier with version `v2.2.1`

```bash
npm install -g prettier@2.2.1
```

Install plugin for elixir templates

```bash
npm install -g prettier prettier-plugin-eex
```

## Enable `eex` parser for `heex` files.

To enable the `eex` plugin for `heex` files, we need to indicate to prettier that we want to use `eex` parser for `heex` files. This can be done on the config file `~/.prettierrc.json`

```json
{
....
  "overrides": [
      {
        "files": "*.heex",
        "options": {
          "parser": "eex"
        }
      }
    ]
....
}
```

## BONUS: Formatting with Vim

My preferrred way of handling formatting for these files is using a manual approach, pressing some key binding for it. For example, adding this line to the `.vim` config, we will be able to trigger the formatter when pressing `CTRL+f`:

```vim
au FileType eelixir nnoremap <leader>f :silent %!prettier --stdin-filepath  %<CR>
```

In case of any error in the formatting, the error will be shown in the current buffer overriting the file. This can be quite annoying but for me it is okay since you can just press `u` and apply a fix based on the error output.

But if you want a more automatic approach, it is possible to use [ALE fixer](https://github.com/dense-analysis/ale) for this, so adding this to the `.vim` config:

```vim
" It may be needed to install ALE from scratch:
" Checkout https://github.com/dense-analysis/ale

"Indicates ALE Fixer for eex/leex/heex 
let g:ale_fixers.eelixir = ["prettier"]

" Apply ALE fixers on save
let g:ale_fix_on_save = 1
```

The main drawback of the latest approach is that we won't get any output in case of any error when applying the formatter. It may make sense to keep the manual approach in order to see any error.

