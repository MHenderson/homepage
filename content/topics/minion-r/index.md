---
title: minion-r
author: Matthew Henderson
date: "2021-05-13"
slug: minion-r
categories:
  - constraint-satisfaction
---

I have been a user of the
[Minion](https://constraintmodelling.org/minion/)
constraint solver
for a number of years.

Lately,
I've been writing code
to make it easier
to work with Minion
and R.

I have three R
packages
which are collected together
under the
[minion-r](https://github.com/minion-r)
organisation on Github:

* The objective with
[{rminion}](/projects/rminion)
is to implement a minimal
interface to Minion from R.
{rminion}
only does minimal parsing
of the result
of calling Minion
and it provides
no facilities for generating
Minion input files.
* The
[{minionator}](/projects/minionator)
package
is for generating Minion
input problems in R.
See
[Introducing Minionator](/post/2020/07/18/minionator/)
for an introduction to Minionator.
* Finally, the
[{mopr}](/projects/mopr)
package implements parsing
of Minion output.
