---
author: "Juan Carlos Martinez de la Torre"
date: 2022-01-14
linktitle: vim-macros-notes 
title: Vim macros notes 
intro: Some useful command/tips when working with macros in VIM 
toc: false

---


> Macros are ideal for repeating changes over a set of similar lines. [(Practical Vim)](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/)


Useful commands gathered when learning about Vim macros.


| key | function   | example |
|---|---|---|
|q   | Both as the "record" button and "stop" button   | `q`  |
|q{register}   | Start macro recording on {register} | `qa`   |
|q{reg}{com}q| Record command on register | `qaAvar<Esc>q` | 
|:reg {register} | Inspect macro register | `:reg a` |
|@{register} | Apply sequence stored at register| `@a` |
|{N}@{register} | Execute macro N times | `10@a` |


**Tips:** 
  - Normalize cursor position -> Use word-wise (`w`, `e` ...) movements instead of character-wise.
  - A macro stops as soon an error happens. Case when using `{N}@{reg}`. This is know as serial execution.   
  - Parallel execution to avoid that a single error stops all the macros: 
    - Select using visual selection: `VG`
    - Apply command -> `:'<', >normal @a`
