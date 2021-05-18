---
title: (WIP) Introducing Minionator
author: Matthew Henderson
date: '2020-07-18'
slug: minionator
categories:
  - constraints
tags:
  - r-packages
  - r
  - minion-r
draft: yes
---

Over the past few weeks
I've been working
on a new R package
for generating constraint programs
for the
[Minion](https://constraintmodelling.org/minion/)
constraint solver.

With Minion you specify
a constraint program
as an input file
and use Minion to find
solutions,
if any exist.

## A very simple constraint program

Here is an example
of a simple Minion input file.

```
MINION 3

**VARIABLES**
DISCRETE l[3,3] {0..2}

**SEARCH**
PRINT ALL

**CONSTRAINTS**
alldiff(l[0,_])
alldiff(l[_,0])
alldiff(l[1,_])
alldiff(l[_,1])
alldiff(l[2,_])
alldiff(l[_,2])

**EOF**
```

This input file
is one possible
way of specifying
a latin square of order 3.

* In the
`**VARIABLES**`
section I specify
a 3 x 3 matrix
of discrete variables
with domain {0 .. 2}.

* In the
`**SEARCH**`
section
I have asked
Minion to print
every solution it finds.

* The
`**CONSTRAINTS**`
are all
`alldiff` constraints.
Here I simply
asking that the symbols
in each row
and each column
are different from each other.
This is just
one way of defining
a latin square.

## Solving with {rminion}



A file containing the above
Minion-format constraint problem
can be downloaded from the
[ls-minion]()
repository.


```r
problem_file <- tempfile()

ls_url <- "https://raw.githubusercontent.com/MHenderson/ls-minion/master/3x3_ls.minion"

download.file(ls_url, problem_file)
```

We can search for a solution
by calling the
`minion`
function
from the
{rminion}
package
and passing the output
directly to the
`first_solution`
function from the
{mopr}
package.


```r
library(rminion)

first_solution(minion(problem_file))
```

```
## Running minion /tmp/RtmpsFsgHg/file258f799da964
```

```
##      [,1] [,2] [,3]
## [1,]    0    1    2
## [2,]    1    2    0
## [3,]    2    0    1
```

The solution
is,
indeed,
a latin square
of order 3.

{rminion} can also be used to enumerate (or even explicitly construct) all latin squares of order 3.


```r
solutions_found(minion(c("-findallsols", "-noprintsols", problem_file)))
```

```
## Running minion -findallsols -noprintsols /tmp/RtmpsFsgHg/file258f799da964
```

```
## [1] 12
```

Indeed,
[there are 12 latin squares of order 3](https://oeis.org/A002860).

## The Minionator package

The Minionator package I've been working on
helps you to use R to construct such input files.

In Minionator, a constraint program is a list with components variables, search, unary_constraints, binary_constraints etc ....

The variables
and the constraints
are both data frames.

If we want to repeat
the latin square example above
then we need
to begin with a 3x3 matrix
of discrete variables
with domain `{0:2}`.

In Minionator we do
this with the
`discrete_matrix`
function.


```r
library(minionator)
library(tidyverse)

(l <- discrete_matrix(3, 3, 0:2))
```

```
## # A tibble: 9 x 6
##     row   col lower upper name  type    
##   <int> <int> <int> <int> <chr> <chr>   
## 1     0     0     0     2 l     DISCRETE
## 2     1     0     0     2 l     DISCRETE
## 3     2     0     0     2 l     DISCRETE
## 4     0     1     0     2 l     DISCRETE
## 5     1     1     0     2 l     DISCRETE
## 6     2     1     0     2 l     DISCRETE
## 7     0     2     0     2 l     DISCRETE
## 8     1     2     0     2 l     DISCRETE
## 9     2     2     0     2 l     DISCRETE
```

A constraint in Minionator
is represented by a data frame
with two columns,
`constraint` and `variables`.
The `constraint` column
simply names the constraint
while the `variables`
column is usually a list
of subset of the variable
data frame.

So,
for example,
if I want to
have an alldifferent
constraint over the variables
in row 0
then I can construct
the data frame


```r
tribble(
~constraint,             ~variables,
  "alldiff", l %>% filter(row == 0)
  )
```

```
## # A tibble: 1 x 2
##   constraint variables           
##   <chr>      <list>              
## 1 alldiff    <tibble[,6] [3 × 6]>
```

For the latin square example we need alldiff constraints on the rows and columns of the input matrix.


```r
L <- list(
          variables = l,
             search = "PRINT ALL",
  unary_constraints = tribble(
  ~constraint,             ~variables,
    "alldiff", l %>% filter(row == 0),
    "alldiff", l %>% filter(row == 1),
    "alldiff", l %>% filter(row == 2),
    "alldiff", l %>% filter(col == 0),
    "alldiff", l %>% filter(col == 1),
    "alldiff", l %>% filter(col == 2)
  )
)
```

3x3 latin square in Minionator (without any functions).

To turn this list into a Minion input file we call minion_output(). If we want to write the output to a file as well then we can call write_file() on the output.


```r
minion_output(L)
```

```
## MINION 3
## **VARIABLES**
## DISCRETE l[3,3] {0..2}
## **SEARCH**
## PRINT ALL
## **CONSTRAINTS**
## alldiff([l[0,0],l[0,1],l[0,2]])
## alldiff([l[1,0],l[1,1],l[1,2]])
## alldiff([l[2,0],l[2,1],l[2,2]])
## alldiff([l[0,0],l[1,0],l[2,0]])
## alldiff([l[0,1],l[1,1],l[2,1]])
## alldiff([l[0,2],l[1,2],l[2,2]])
## 
## 
## **EOF**
```

So far there isn’t really much point to this. The Minionator list version of the input file is even longer than the Minion input file itself. So why use Minionator?

Suppose now you want to find larger latin squares. If you create a Minion input file by hand then you will have to write a lot more code than the Minionator version. A better approach would be to write a function that generates the output. We can easily write functions to generate the row and column constraints from a parameter equal to the order of the latin square.
