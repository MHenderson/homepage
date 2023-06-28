---
title: Introduction to Greedy Colouring
author: Matthew Henderson
date: '2014-05-23'
slug: introduction-to-greedy-colouring
categories:
  - graph-theory
tags:
  - graph-colouring
  - ccli
subtitle: ''
excerpt: "Introducing Culberson's graph colouring programs."
draft: no
series: ~
layout: single
---

In the post we discuss Joseph Culberson’s
[Graph Colouring Programs](http://webdocs.cs.ualberta.ca/~joe/Coloring/Colorsrc/),
a collection of C programs which can be downloaded from
[Culberson’s Graph Colouring Page](http://webdocs.cs.ualberta.ca/~joe/Coloring/).

This post has four sections. In the first, we show to use `greedy` in the
manner it was designed to be used, interactively. In the second section we
introduce a new wrapper interface, `ccli`, which can be used to drive `greedy`
and the other of Culberson’s Colouring Programs in a non-interactive way which
is suitable for automated experimentation and has benefits for reproducibility.
In the third section we describe a general scheme for using `greedy` to
approximate the chromatic number of graphs. In the final section we demonstrate
this approach through a toy experiment into the chromatic number of queen
graphs.

## Interactive usage

All of Culberson’s Colouring Programs, including `greedy`, require input graph
data to be given in
[DIMACS](http://mat.gsia.cmu.edu/COLOR/general/ccformat.ps)
format. In this section we will demonstrate
how to use `greedy` to find a colouring of the Chvatal Graph which can be
found in
[DIMACS format](https://raw.github.com/MHenderson/graphs-collection/master/src/Classic/Chvatal/chvatal.dimacs)
in the
[graphs-collection](http://mhenderson.github.io/graphs-collection/)
collection of graphs.

To use `greedy` to colour a graph, call the program from the command-line and
pass the path to the graph data in DIMACS format as an argument.

    $ greedy chvatal.dimacs

After an interactive session, detailed below, the resulting colouring will be
appended to `a.res` (where `a` is the original filename, including extension).
This file will be created if it doesn’t already exist.

Before the colouring is produced, however, we have to participate in an
interactive session with `greedy` to determine some options used by the
program in producing the colouring. The first of these options is about whether
we wish to a use a cheat colouring inside the input file as a target colouring.
The purpose of this cheat is explained further in the
`greedy`
[documentation](http://webdocs.cs.ualberta.ca/~joe/Coloring/Colorsrc/manual.html).
We won’t be using it here, so we respond negatively.

    J. Culberson's Implementation of
            GREEDY
    A program for coloring graphs.
    For more information visit the webpages at:

        http://www.cs.ualberta.ca/~joe/Coloring/index.html

    This program is available for research and educational purposes only.
    There is no warranty of any kind.

        Enjoy!

    Do you wish to use the cheat if present? (0-no, 1-yes)
    0

The next option we are prompted for is a seed to be used for randomisation.
This provides us with the ability to generate different random colourings
and also to reproduce previously randomised colourings.

    ASCII format
    number of vertices = 12
    p edge 12 24
    Number of edges = 24 edges read = 24
    GRAPH SETUP cpu =  0.00
    Enter seed for search randomization:
    1

Responding with 1 leads us to a choice about the type of greedy algorithm we
want to use. There are six types. Again, for more information see the greedy
documentation. For now we will use the simple greedy algorithm.

    Process pid = 5315
    GREEDY TYPE SELECTION
        1	Simple Greedy
        2	Largest First Greedy
        3	Smallest First Greedy
        4	Random Sequence Greedy
        5	Reverse Order Greedy
        6	Stir Color Greedy
    Which for this program
    1

The next option concerns the way in which vertices are ordered before the
algorithm starts running. The default is `inorder`, the order vertices are
given in the input graph file.

    Initial Vertex Ordering:
        1 -- inorder
        2 -- random
        3 -- decreasing degree
        4 -- increasing degree
        5 -- LBFS random
        6 -- LBFS decreasing degree
        7 -- LBFS increasing degree
    Using:
    1

Choosing inorder for our initial vertex ordering leads us to the final option,
whether or not we wish the algorithm to use the method of Kempe reductions.

    Use kempe reductions y/n
    n

The output is in a file called `chvatal.dimacs.res` and, after only one call,
looks like this:

    CLRS 4 FROM GREEDY cpu =  0.00 pid = 5315
      1   2   1   2   3   1   2   1   2   3   4   4

This is to be interpreted as a colouring of vertices. The first vertex gets
colour 1, the second colour 2, the third colour 1 and so on. With multiple
calls this file is augmented with additional lines of data in this format.
This gives us a simple way of collecting information about many different
runs of the same program, possibly with different options, on the same data.

## Non-Interactive Use

In some situations, especially when running multiple simulations with different
parameters, it can be useful to use programs non-interactively. Other benefits
to this approach are that it makes it easier to chain commands together in a
shell environment, for example to take the output of a colouring program and
use it as part of the input to another program that draws a graph and colours
nodes according to the resulting colouring. Another benefit is that it makes
easier the task of documenting and communicating experimental conditions. This,
in turn, can have benefits for reproducibility of results.

For this reason we have developed `ccli`
*Culberson’s (Colouring Programs) Command-Line Interface*, a wrapper script
around Culberson’s programs that gives them a non-interactive interface.
Although still under development, `ccli` currently can provide a complete
interface to several of the programs, including `greedy`.

[`ccli`](https://github.com/MHenderson/ccli)
is built on
[`docopts`](https://github.com/docopt/docopts)
and
[`expect`](http://expect.sourceforge.net/)
and requires
both of those programs to be installed as well as Bash 4.0 or newer.

This is the usage pattern for `ccli`:

    ccli algorithm [options] [--] <file>...

where `algorithm` is one of `bktdsat`, `dsatur`, `greedy`, `itrgreedy`, `maxis`
or `tabu`. The options list allows us to specify any of the same options
that we would specify with the interactive interface. For example, to use
the embedded cheats we add the `--cheat` switch to the options list. For a
full explanation of all options, consult the online documentation of `ccli`
(`ccli --help`).

For example, to use `ccli` to colour the Chvatal graph file above with the
`greedy` algorithm of simple type with inorder vertex ordering we call `ccli`
like so:

    ccli greedy --type=simple --ordering=inorder chvatal.res

Options that are not explicitly specified on the command-line default to
values which can be seen in the usage documentation (`ccli --help`). For
example, the default for `--cheat` is for it to be disabled.

As before, the colouring output of this call is augmented to the
`chvatal.col.res` file. Future versions of `ccli` will support output to
the standard output which will allow `ccli` to be used in the manner of
other Unix programs discussed above.

## Bounds for the Chromatic Number

The greedy algorithm, both in theory and practice, is a useful tool for
bounding the chromatic number of graphs. For if we have a colouring of a
graph with `\(k\)` colours then we know that the chromatic number of that graph
is at most `\(k\)`.

Imagine that we have used `greedy` many times to produce a file `a.dimacs.res`
which contains many different colourings of the graph `a.dimacs`. Then we can
use a `sed` one-liner to extract the number of colours used by each colouring
and put the results into a file.

    $ sed -n `s/CLRS \([0-9]+\) [A-Z a-z = 0-9 .]*/\1/p` a.dimacs > output.txt

Now `output.txt` should contain several lines, each containing a single integer,
the number of colours used in the corresponding colouring. To find the smallest
of these values is just a matter of sorting the file numerically and reading
the value in the first line. We put this number into a file for later
inspection.

    $ sort -n output.txt | head -n 1 > approx.txt

Now the file `approx.txt` contains a our best estimate for the chromatic number.

Using these little hacks we can devise a simple scheme to use `ccli` to estimate
the chromatic number of a graph.

- Generate a large number of different colourings,
- For each colouring, compute the colouring number,
- Find the smallest colouring number over all colourings,
- Record this value as an approximation to the chromatic number.

If the colourings that we generate are all the same colouring then all of the
numbers are the same. If we use Culberson’s programs in a deterministic way
then we can only hope to generate a number of colourings equal to the number
of combinations of algorithm and vertex orderings. Fortunately, the
non-deterministic features of these programs give us the chance to generate
a lot of different colourings and hopefully come up with better approximations.

The design of `ccli` makes it very easy to generate a lot of colourings from
the shell. We simply write a loop:

    !#/bin/bash
    for (( i=1; i<=$1; ++i ))
    do
     ccli greedy --type=$2 --ordering=$3 --seed=$RANDOM $4
    done

This loop has been written in the form of a script which takes four
parameters. The first is a number of iterations, the second is the algorithm
type, third is the vertex ordering and the fourth is the path to the graph in
DIMACS format. The \$RANDOM variable is a Linux environment variable which
generates a random integer and we this used to seed the random number generator
in the `greedy` program. This means that each iteration produces a different
colouring.

## Bounds for the Chromatic Number of Queen Graphs

We have applied the above scheme to
[queen graphs](http://mathworld.wolfram.com/QueenGraph.html)
A *queen
graph* is a graph whose vertices are the squares of a chessboard and edges
join squares if and only if queens placed on those squares attack each other.

The chromatic number of queen graphs is still an open problem in general.
According to the
[Online Encyclopedia of Integer Sequences](http://oeis.org)
the
[chromatic number of the queen graph](http://oeis.org/A088202)
of size 26 is unknown. Chvatal
[claims](http://users.encs.concordia.ca/~chvatal/queengraphs.html)
that in 2005 a 26-colouring of the queen graph of dimension
26 was found and thus 27 is the smallest unknown order. This follows because
the chromatic number of a `\(n \times n\)` queen graph is at least `\(n\)` and thus
a 26-colouring of the `\(26 \times 26\)` queen graph proves that the chromatic
number is 26.

In the table below we list graphs from Michael Trick’s
[colouring instances page](http://mat.gsia.cmu.edu/COLOR/instances.html)
In the first column is the chromatic
number, if known. Subsequent columns give approximations based on different
parameters for `greedy`. The parameters are described in the list below the table.

The final column is the quality of the approximation, given by the ratio of the
least colouring number over all colourings `\(\chi_{a}\)` to the chromatic number
`\(\chi\)`.

| Filename       | `\(\chi\)` | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | X   | `\(\frac{\chi_{a}}{\chi}\)` |
|----------------|------------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----------------------------|
| queen5_5.col   | 5          | 5   | \-  | \-  | \-  | \-  | \-  | \-  | \-  | \-  | \-  | 1.000                       |
| queen6_6.col   | 7          | 8   | 8   | 8   | 8   | 8   | 7   | \-  | \-  | \-  | \-  | 1.000                       |
| queen7_7.col   | 7          | 9   | 9   | 9   | 9   | 9   | 9   | 10  | 10  | 9   | 8   | 1.143                       |
| queen8_8.col   | 9          | 11  | 11  | 11  | 11  | 11  | 10  | 11  | 11  | 11  | 11  | 1.111                       |
| queen9_9.col   | 10         | 13  | 12  | 12  | 12  | 12  | 12  | 13  | 12  | 12  | 12  | 1.200                       |
| queen10_10.col | 11         | 14  | 14  | 14  | 14  | 14  | 13  | 13  | 14  | 14  | 14  | 1.182                       |
| queen11_11.col | 11         | 15  | 15  | 15  | 15  | 15  | 15  | 15  | 15  | 15  | 15  | 1.364                       |
| queen12_12.col | 12         | 17  | 17  | 17  | 16  | 16  | 16  | 16  | 16  | 16  | 17  | 1.333                       |
| queen13_13.col | 13         | 19  | 18  | 18  | 18  | 18  | 17  | 18  | 18  | 18  | 18  | 1.308                       |
| queen14_14.col | 14         | 20  | 20  | 19  | 19  | 19  | 19  | 19  | 19  | 19  | 20  | 1.357                       |
| queen15_15.col | 15         | 21  | 21  | 21  | 20  | 20  | 20  | 20  | 21  | 21  | 21  | 1.333                       |
| queen16_16.col | 16         | 23  | 23  | 22  | 21  | 22  | 21  | 21  | 22  | 22  | 22  | 1.312                       |

The columns in the above table refer to the following parameter settings:

1.  `--type=random --ordering=random` (iterations 500)
2.  `--type=random --ordering=random` (iterations 1000)
3.  `--type=random --ordering=random` (iterations 5000)
4.  `--type=simple --ordering=random` (iterations 500)
5.  `--type=simple --ordering=random` (iterations 1000)
6.  `--type=simple --ordering=random` (iterations 5000)
7.  `--type=simple --ordering=lbfsr` (iterations 500)
8.  `--type=simple --ordering=lbfsr` (iterations 1000)
9.  `--type=simple --ordering=lbfsr` (iterations 5000)
    X. `--type=random --ordering=lbfsd` (iterations 10000)

## Source Code

{{% gist "MHenderson" "a2cc887ee45b17b4e53d" %}}
