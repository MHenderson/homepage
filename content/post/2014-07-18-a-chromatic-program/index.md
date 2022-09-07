---
title: "A Chromatic Number Program"
author: Matthew Henderson
date: '2014-07-18'
description: A script for computing the chromatic number, based on the Tutte polynomial.
slug: chromatic-program
categories:
  - graph-theory
tags:
  - maxima
  - bash
  - graphviz
---

The [chromatic polynomial][def:chromatic_polynomial] `\(\chi(G, \lambda)\)`
allows us to determine the [chromatic number][def:chromatic_number] of `\(G\)` as
`\(\chi(G) = \min\{\lambda \in \{1,\ldots,\Delta(G) + 1\}\,|\, \chi(G, \lambda) > 0\}\)`

Computationally, though, the chromatic polynomial is an expensive object to
construct. However, we can still use this method to calculate the chromatic
numbers of small graphs.

In this blog we try to find more than one method for every calculation and for
every method we try to give more than one implementation. This is because,
ultimately, we hope to have reliable, reproducible results. As far as
reliability goes, redundancy in our data is important and so, for this
reason, here we provide another implementation of the chromatic number based
on the chromatic polynomial.

In the previous post we used exclusively NetworkX for the implementation. Here
we use traditional GNU utilities like Sed, cat, tr and tail, the Graphviz
program gvpr, the GNU Maxima computer algebra system and an implementation
of the Tutte polynomial by Haggard, Pearce and Royle.

## Chromatic Numbers of Small DOT Graphs

Our program, which is little more than a wrapper script, takes as input a
graph in DOT format and outputs the chromatic number. The program works by
following the four steps below.

1. compute the maximum degree of the input graph,
2. convert the Graphviz data file into the input graph format used by the
   `tutte` program,
3. compute the chromatic polynomial using `tutte`,
4. compute the chromatic number using GNU Maxima.

The only non-trivial work here is done by the `tutte` and Maxima programs.
Our script is simply a driver or wrapper providing a convenient interface.
In fact, the dependency on GNU Maxima here could doubtless be removed because
`tutte` is able to compute values of the polynomials it computes.

In a forthcoming post we will use the program described in this post to
reproduce, and hopefully extend, the data from last week's post on chromatic
numbers of small graphs. In the rest of this post we describe each of the
four steps above in detail.

## Maximum Degree Computation

Some graph data formats include parameter data like number of vertices and
number of edges. In this context we assume that we have a graph in DOT format
without any additional parameter data. As it turns out, the `tutte` program
infers the parameter data it needs from the graph input. So we are only left
with need to calculate the maximum degree which is needed outside of `tutte`
as the upper limit of the main loop.

A *gvpr* program, [`maxdeg`][maxdeg] computes the maximum and minimum degree
of graphs in DOT format.

    $ curl -s https://raw.githubusercontent.com/MHenderson/graphs-collection/master/src/Classic/Chvatal/chvatal.gv\
      | gvpr -f maxdeg
    max degree = 4, node 0, min degree = 4, node 0

To use this program in our final pipeline we simply scrape out the maximum
degree value from this output using Sed:

    $ ...
      | sed -n 's/max degree = \([0-9]*\).*/\1/p'
    4

## Convert Graph Format

The input format for `tutte` is quite similar to the DOT format that we are
using as the input format for our program. In the `tutte` format, edges are
designated by a string of the form `x--y` and a graph is a comma separated
list of edges.

To convert a graph in DOT format into the `tutte` input format can thus be
accomplished by:

1. matching edges of the form `x -- y;` and replacing them with edges of the
   form `x--y,`,
2. removing all whitespace, including newlines,
3. removing the final, extraneous comma.

A pipeline involving Sed and `tr` is by no means the only way to accomplish
this sequence of replacements but suffices for our purposes.

    $ curl -s https://raw.githubusercontent.com/MHenderson/graphs-collection/master/src/Classic/Chvatal/chvatal.gv\
      | sed -n 's/\([0-9]*\) -- \([0-9]*\);/\1--\2,/p'\
      | tr -d ' \t\n\r\f'\
      | sed '$s/.$//'
    0--1,0--4,0--6,0--9,1--2,1--5,1--7,2--3,2--6,2--8,3--4,3--7,3--9,4--5,4--8,5--10,5--11,6--10,6--11,7--8,7--11,8--10,9--10,9--11

## Compute the Chromatic Polynomial

There is almost nothing to this step. We simply call the `tutte` program on the
data from the previous step and scrape the output for the polynomial string
result.

The important options for `tutte` in this context are `--stdin` which tells
`tutte` to expect input from standard input and `--chromatic` which asks for
the chromatic, as opposed to Tutte, polynomial.

    $ curl -s https://raw.githubusercontent.com/MHenderson/graphs-collection/master/src/Classic/Chvatal/chvatal.gv
      | sed -n -e 's/\([0-9]*\) -- \([0-9]*\);/\1--\2,/p'
      | tr -d ' \t\n\r\f'| sed '$s/.$//'
      | tutte --chromatic --stdin
    G[1] := {0--1,0--4,0--6,0--9,1--2,1--5,1--7,2--3,2--6,2--8,3--4,3--7,3--9,4--5,4--8,5--10,5--11,6--10,6--11,7--8,7--11,8--10,9--10,9--11}
    CP[1] := -1 * x * ( 1994*(1-x) + 7427*(1-x)^2 + 12339*(1-x)^3 + 12360*(1-x)^4 + 8445*(1-x)^5 + 4191*(1-x)^6 + 1559*(1-x)^7 + 438*(1-x)^8 + 91*(1-x)^9 + 13*(1-x)^10 + 1*(1-x)^11 ) :

The chromatic polynomial is everything between `G[1] := ` and ` : `. This
delimitation makes extraction with Sed easy:

    $ ...
      | sed -n 's/^CP\[1\] :=\(.*\) :/\1/p'
     -1 * x * ( 1994*(1-x) + 7427*(1-x)^2 + 12339*(1-x)^3 + 12360*(1-x)^4 + 8445*(1-x)^5 + 4191*(1-x)^6 + 1559*(1-x)^7 + 438*(1-x)^8 + 91*(1-x)^9 + 13*(1-x)^10 + 1*(1-x)^11 )

## Compute the Chromatic Number

Now that we have a string representation of the chromatic polynomial we
compute the chromatic number as the least positive integer for which the
represented polynomial has a positive value. As `\(\chi(G) \leq \Delta(G) + 1\)`
for all graphs `\(G\)`, this can require the computation of most
`\(\Delta(G) + 1\)` values of the chromatic polynomial.

To compute a value of the chromatic polynomial from the string representation
output by `tutte` we use the GNU Maxima computer algebra software. The `at`
command of Maxima returns the value of its first argument polynomial string
at the value of variables given in the second argument. For example, if `cp`
is the string from the previous step then `at(cp, x = 0)` is the value of the
polynomial represented by `cp` at `x = 0`.

    m: `\({max_degree}\)`
    cp: `\({cp}\)`
    chi: for i: 1 thru m + 1 do
           if at(cp, x = i) > 0 then return (i)$
    print(chi);

Maxima is an interactive program but can also be used non-interactively through
the `--batch` or `--batch-string` options. The latter is sufficient for us,
because our Maxima program is very short.

    s="
    m: `\({max_degree}\)`
    cp: `\({cp}\)`
    chi: for i: 1 thru m + 1 do
           if at(cp, x = i) > 0 then return (i)$
    print(chi);"

    maxima --batch-string="$s"

The default output of Maxima includes a license header and all input and
output, including labels. The header can be switched off using the
`--very-quiet` option. This option also removes the labels from input and
output text. So now to scrape out the chromatic number itself we use `tail`
to restrict our view of the output to the last line. The chromatic number
is centred on this line so we remove whitespace using `tr`.

    maxima --very-quiet --batch-string="$s"\
      | tail -n 1\
      | tr -d ' \t\r\f'

## Source Code

{% gist MHenderson/49f1b3a0b1f9132e1dbe %}

[maxdeg]: https://github.com/ellson/graphviz/blob/master/cmd/gvpr/lib/maxdeg
[gistllink]: https://gist.github.com/MHenderson/49f1b3a0b1f9132e1dbe

