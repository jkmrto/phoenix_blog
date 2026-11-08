---
author: "Juan Carlos Martinez de la Torre"
date: 2022-01-14
linktitle: vim-macros-notes 
title: Vim macros notes 
intro: Some useful commands and tips for working with macros in Vim
toc: false

---


> Macros are ideal for repeating changes over a set of similar lines. [(Practical Vim)](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/)


Useful commands gathered when learning about Vim macros.


| key | function   | example |
|---|---|---|
|q   | Acts as both the "record" and the "stop" button   | `q`  |
|q{register}   | Start macro recording on {register} | `qa`   |
|q{reg}{com}q| Record command on register | `qaAvar<Esc>q` | 
|:reg {register} | Inspect macro register | `:reg a` |
|@{register} | Apply the sequence stored in register| `@a` |
|{N}@{register} | Execute macro N times | `10@a` |


**Tips:** 
  - Normalize the cursor position -> use word-wise (`w`, `e` ...) movements instead of character-wise ones.
  - A macro stops as soon as an error happens. This is the case when using `{N}@{reg}`, known as serial execution.   
  - Use parallel execution to prevent a single error from stopping all the macros: 
    - Select using visual selection: `VG`
    - Apply command -> `:'<', >normal @a`
