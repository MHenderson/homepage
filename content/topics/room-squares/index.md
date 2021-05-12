---
title: Room Squares
author: Matthew Henderson
date: "2021-05-11"
slug: room-squares
categories:
  - combinatorics
tags:
  - room-squares
---

A **Room square**
is an `\(n × n\)` array filled with `\(n + 1\)`
different symbols in such a way that:

  1. Each cell of the array is either empty or contains an unordered pair
     from the set of symbols
  2. Each symbol occurs exactly once in each row and column of the array
  3. Every unordered pair of symbols occurs in exactly one cell of the array.

![seven by seven room square coloured by min value](https://raw.githubusercontent.com/MHenderson/tidy-room-squares/master/min.png)
![seven by seven room square coloured by max value](https://raw.githubusercontent.com/MHenderson/tidy-room-squares/master/max.png)

(Both of these images are of the same Room square.
The one on the left is coloured by the minimum
value in each filled cell. The one on the right
is coloured according to the maximum value.)

I'm writing a
[monograph](/projects/room)
about Room squares.

I've also started working
on an [annotated bibliography](/projects/room-squares-bib)
about Room squares.

A few years ago,
I wrote some Visual Basic code
for generating Room squares
using Dinitz and Stinson's
hill-climbing approach.
Lately,
I've been working
on a
[Java version](/projects/room-square-generator).