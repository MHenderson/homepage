---
title: rminion
author: Matthew Henderson
categories:
  - projects
date: "2021-03-08"
slug: rminion
tags:
  - constraint-satisfaction
  - r-packages
  - r
draft: true
---

An R package for calling Minion.

* [source](https://github.com/minion-r/rminion) - on Github

## Installation

``` r
remotes::install_github("MHenderson/rminion")
```

## Example: Donald, Gerald, Robert

``` r
dgr <- "
MINION 3
**VARIABLES**
DISCRETE a{0..9}
DISCRETE b{0..9}
DISCRETE d{0..9}
DISCRETE e{0..9}
DISCRETE g{0..9}
DISCRETE l{0..9}
DISCRETE n{0..9}
DISCRETE o{0..9}
DISCRETE r{0..9}
DISCRETE t{0..9}
**SEARCH**
VARORDER [a,b,d,e,g,l,n,o,r,t]
VALORDER [a,a,a,a,a,a,a,a,a,a]
SYMORDER [a,b,d,e,g,l,n,o,r,t]
PRINT[[a],[b],[d],[e],[g],[l],[n],[o],[r],[t]]
**CONSTRAINTS**
weightedsumleq([100000,10000,1000,100,10,1,100000,10000,1000,100,10,1,-100000,-10000,-1000,-100,-10,-1], [d,o,n,a,l,d,g,e,r,a,l,d,r,o,b,e,r,t], 0)
weightedsumgeq([100000,10000,1000,100,10,1,100000,10000,1000,100,10,1,-100000,-10000,-1000,-100,-10,-1], [d,o,n,a,l,d,g,e,r,a,l,d,r,o,b,e,r,t], 0)
gacalldiff([a,b,d,e,g,l,n,o,r,t])
**EOF**"
```

``` r
library(readr)

dgr_file <- tempfile()
write_file(dgr, dgr_file)
```

``` r
library(rminion)

minion(dgr_file)
#> Running minion /tmp/RtmpM6FffP/file6a7325c6d10a
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] "# Minion Version 1.8\n# HG version: 0\n# HG last changed date: unknown\n#  Run at: UTC Fri Jan  1 17:08:50 2021\n\n#    http://minion.sourceforge.net\n# If you have problems with Minion or find any bugs, please tell us!\n# Mailing list at: https://mailman.cs.st-andrews.ac.uk/mailman/listinfo/mug\n# Input filename: /tmp/RtmpM6FffP/file6a7325c6d10a\n# Command line: minion /tmp/RtmpM6FffP/file6a7325c6d10a \nParsing Time: 0.000000\nSetup Time: 0.000000\nFirst Node Time: 0.000000\nInitial Propagate: 0.000000\nFirst node time: 0.000000\nSol: 4 \nSol: 3 \nSol: 5 \nSol: 9 \nSol: 1 \nSol: 8 \nSol: 6 \nSol: 2 \nSol: 7 \nSol: 0 \n\nSolution Number: 1\nTime:0.100000\nNodes: 13873\n\nSolve Time: 0.160000\nTotal Time: 0.160000\nTotal System Time: 0.000000\nTotal Wall Time: 0.158444\nMaximum RSS (kB): 79760\nTotal Nodes: 13873\nProblem solvable?: yes\nSolutions Found: 1\n"
#> 
#> $stderr
#> [1] ""
#> 
#> $timeout
#> [1] FALSE
```
