---
title: (WIP) Introducing Minionator
author: Matthew Henderson
date: '2020-07-18'
slug: minionator
categories:
  - posts
tags:
  - r-packages
  - r
  - minion-r
  - constraint-programming
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

## Using Minion to find solutions

If the file `ls.minion` contains
this text
then calling minion
with `ls.minion` as the only argument
finds a solution.


```r
system2("/home/matthew/workspace/minion", args = "/home/matthew/workspace/ls.minion", stdout = TRUE)
```

```
##  [1] "# Minion Version 1.8"                                                             
##  [2] "# HG version: 0"                                                                  
##  [3] "# HG last changed date: unknown"                                                  
##  [4] "#  Run at: UTC Wed Mar 24 18:12:43 2021"                                          
##  [5] ""                                                                                 
##  [6] "#    http://minion.sourceforge.net"                                               
##  [7] "# If you have problems with Minion or find any bugs, please tell us!"             
##  [8] "# Mailing list at: https://mailman.cs.st-andrews.ac.uk/mailman/listinfo/mug"      
##  [9] "# Input filename: /home/matthew/workspace/ls.minion"                              
## [10] "# Command line: /home/matthew/workspace/minion /home/matthew/workspace/ls.minion "
## [11] "Parsing Time: 0.000000"                                                           
## [12] "Setup Time: 0.000000"                                                             
## [13] "First Node Time: 0.000000"                                                        
## [14] "Initial Propagate: 0.000000"                                                      
## [15] "First node time: 0.000000"                                                        
## [16] "Sol: 0 1 2 "                                                                      
## [17] "Sol: 1 2 0 "                                                                      
## [18] "Sol: 2 0 1 "                                                                      
## [19] ""                                                                                 
## [20] "Solution Number: 1"                                                               
## [21] "Time:0.000000"                                                                    
## [22] "Nodes: 4"                                                                         
## [23] ""                                                                                 
## [24] "Solve Time: 0.060000"                                                             
## [25] "Total Time: 0.060000"                                                             
## [26] "Total System Time: 0.008000"                                                      
## [27] "Total Wall Time: 0.079240"                                                        
## [28] "Maximum RSS (kB): 5744"                                                           
## [29] "Total Nodes: 4"                                                                   
## [30] "Problem solvable?: yes"                                                           
## [31] "Solutions Found: 1"
```

The solution is given
by lines 16 - 18 of the output
and is,
indeed,
a latin square of order 3.

It can also be used to enumerate (or even explicitly construct) all latin squares of order 3.


```r
system2("/home/matthew/workspace/minion", args = "-findallsols -noprintsols /home/matthew/workspace/ls.minion", stdout = TRUE)
```

```
##  [1] "# Minion Version 1.8"                                                                                       
##  [2] "# HG version: 0"                                                                                            
##  [3] "# HG last changed date: unknown"                                                                            
##  [4] "#  Run at: UTC Wed Mar 24 18:12:43 2021"                                                                    
##  [5] ""                                                                                                           
##  [6] "#    http://minion.sourceforge.net"                                                                         
##  [7] "# If you have problems with Minion or find any bugs, please tell us!"                                       
##  [8] "# Mailing list at: https://mailman.cs.st-andrews.ac.uk/mailman/listinfo/mug"                                
##  [9] "# Input filename: /home/matthew/workspace/ls.minion"                                                        
## [10] "# Command line: /home/matthew/workspace/minion -findallsols -noprintsols /home/matthew/workspace/ls.minion "
## [11] "Parsing Time: 0.000000"                                                                                     
## [12] "Setup Time: 0.000000"                                                                                       
## [13] "First Node Time: 0.000000"                                                                                  
## [14] "Initial Propagate: 0.000000"                                                                                
## [15] "First node time: 0.000000"                                                                                  
## [16] "Solve Time: 0.000000"                                                                                       
## [17] "Total Time: 0.000000"                                                                                       
## [18] "Total System Time: 0.000000"                                                                                
## [19] "Total Wall Time: 0.000453"                                                                                  
## [20] "Maximum RSS (kB): 1016"                                                                                     
## [21] "Total Nodes: 23"                                                                                            
## [22] "Problem solvable?: yes"                                                                                     
## [23] "Solutions Found: 12"
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
## 1 alldiff    <tibble [3 × 6]>
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

Suppose now you want to find larger latin squares. If you create a Minion input file by hand then you will have to write a lot more code than the Minionator version. A better approach would be to write a function that generates the output. We can easily write functions to generate the row and column constraints from a parameter equal to the order of the latin square. We don’t even need Minionator to do this but if we are using Minionator then we would end up with something like this.

Code for a parameterised version of the latin square generator.

The benefits of using Minionator don’t stop at just allowing us to create large input files more easily. Perhaps the greatest benefit is that the use of data frames to represent the variables and constraints makes it easier to compose constraints and also to construct constraints over complex variable ranges.

As an example, consider the problem of constructing a pair of mutually orthogonal latin squares of order n. If we are working directly with Minion input files then we would have a lot of cutting-and-pasting to do. With Minionator we can just create two discrete matrices and a function that given a matrix returns the latin constraints for that matrix. Now only the orthogonality question remains.

Code for two latin squares using previously demonstrated latin constraints function.

One approach is to use a constraint on vectors. We can insist that in our solution the pair (i,j) is different to the pair (k,l) whenever i<>j or k<>l. To reduce the number of constraints (not necessarily advantageous) we can also insist that i < k. Tools from the tidyverse make it easy to construct this set of indices. The purrr package then makes it easy to construct from a dataframe of these variables a new dataframe which represents the vector inequality constraint over every pair of pairs.

Code for MOLS.

Calling Minion with this input file we can easily find a pair of mutually orthogonal latin squares of order X. Or even enumerate MOLS of small order.

Calling Minion via R to generate MOLS.

We will look at some more examples now and hope to convince you that using Minionator makes life easier in certain cases. I think having your variables and constraints in data frames makes life a lot easier than if you try to write code to do the same thing with strings and loops etc … The main argument is that the tidyverse and related tools makes it easy to build up the data frame of variables and then to subset it in various complicated ways. Of course you could do it all in your own code working with the output strings directly, but you would probably have to rewrite a lot of code similar to what is already available in the tidyverse (or even just base R). A good example is cross_df.