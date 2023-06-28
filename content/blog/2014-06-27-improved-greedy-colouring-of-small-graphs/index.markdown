---
title: Improved Greedy Colouring of Small Graphs
author: Matthew Henderson
date: '2014-06-27'
slug: improved-greedy-colouring-of-small-graphs
categories:
  - graph-theory
tags:
  - graph-colouring
  - ccli
  - dimacs
subtitle: ''
excerpt: "Improved greedy colouring of small graphs with Culberson's colouring programs."
draft: no
series: ~
layout: single
---

In the previous post we conducted a small experiment to compare the total
number of colours used by the greedy vertex colouring algorithm on a collection
of small graphs. The aim of that experiment was to see whether, over a large
number of graphs, the total number of colours used by different degree
orderings was significant. The tool we used was NetworkX. In this post we
revisit this experiment with Culberson’s colouring programs.

As Culberson’s implementation of the greedy colouring algorithm works with
graphs in Dimacs format we need to first generate a collection of small graphs
in that format. Fortunately, on the [homepage of Brendan McKay](http://cs.anu.edu.au/~bdm)
there is a large collection of combinatorial data, including
[small graphs up to order 10](http://cs.anu.edu.au/~bdm/data/graphs.html). These graphs are in *graph6*
format but translating a graph from *graph6* to Dimacs format is not too
difficult thanks to some tools written by McKay for working with graphs in
*graph6* format.

So this is what we are going to do:

1.  Download small graphs in graph6 format from BDM’s combinatorial data pages.
2.  Convert all graphs from graph6 to Dimacs
3.  Split file of Dimacs graphs into files, each containing one graph.
4.  Colour graphs with ccli using different vertex orderings
5.  Compute total colouring numbers per ordering

## Convert from graph6 to Dimacs

The *graph6* format is a format devised by Brendan McKay for the
*nauty* {% cite McKay201494 %} graph isomorphism software. In this post we
won’t attempt to describe how this format is defined. For further information
see the
[graph6 and sparse6 graph formats page](http://cs.anu.edu.au/~bdm/data/formats.html)
on McKay’s homepage. Gordon Royle also has some useful information about
[*graph6* and *sparse6* formats](http://staffhome.ecm.uwa.edu.au/~00013890/g6.html) on his homepage.

The program *listg* (and its companion *showg*) which belongs to the *nauty*
project can display graph6 graphs in various human readable formats. One format
which is easy to convert into other formats is the edge format.

    $ curl -s http://cs.anu.edu.au/~bdm/data/graph2.g6\
      | listg -e

    Graph 1, order 2.
    2 0


    Graph 2, order 2.
    2 1
    0 1

So in `graph2.g6` there are two graphs. The first graph has 2 nodes and 0 edges.
The second graph has 2 nodes and 1 edge. The edge joins vertices 0 and 1.

To convert one of these files into a file of graphs in Dimacs format we use
a combination of Sed and AWK. A Sed one-liner can convert a list of edges of
the form `x y` into the `x -- y` form used in Dimacs. AWK will enable us to
process the file of graphs in the above edge-list format and apply to Sed
one-liner to each graph. The Sed one-liner in question is:

    sed -r -e 's/([0-9]+) ([0-9]+)/ e \1 \2\n/g' $1

Now if we think of one of BDMs files as being made of records, each of
which is a graph and consists of three lines, the third of which is the list
of edges then we can use AWK to convert this into a file of DOT format graphs
like so:

    awk -f e2dimacs.awk output.txt > result.txt

where `e2dimacs.awk` is the following little snippet:

    BEGIN { FS = "\n"; RS = "" }
          { print "p edge " $2 }
          { cmd="echo " $3 " | e2dimacs"; system(cmd) }

and the `e2dimacs` command is the above Sed one-liner.

Putting everything together into one pipeline:

    $ curl -s http://cs.anu.edu.au/~bdm/data/graph2.g6\
      | listg -e\
      | awk -f e2dimacs.awk

    p edge 2 0

    p edge 2 1
     e 0 1

## Split into individual files

Unfortunately, `greedy` expects that an input file contains a single graph to
be coloured. This means that if we want to colour a collection of graphs in one
file we have to split that file into many. One of the easiest methods is to use
AWK.

Suppose we had redirected the output from the last command of the previous
section into a file graph2.g6 then the following command

    awk -f dimacs_split.awk graph2.dimacs

with `dimacs_split.awk` being the AWK program

    BEGIN { FS = "\n"; RS = ""; n=0; }
          { print >> n".dimacs"; n++; }

Creates two files `0.dimacs` and `1.dimacs`, containing the first and second
graph from the original *graph6* file but now converted in Dimacs format.

## Colour with greedy

At this point we have a collection of graphs each in a file of its own. We
want to iterate all such files and run `greedy` with a specific ordering. This
is easy if we know how many graphs are contained in the collection. We can
just create a loop of the write length in Bash and at each step of the loop
we call `ccli` with the correct parameters and the filename based on a loop
index.

    for n in {0..10};\
    do\
      ccli greedy --type=simple --ordering=inorder $n.dimacs;\
    done

## Compute colouring numbers

The output of calling `greedy` on a file `n.dimacs` is a file `n.dimacs.res`
in the same folder as the first file and containing the colouring data. The
line preceding the colouring itself also contains the number of colours used
and we can extract this number using another Sed one-liner:

    sed -n 's/CLRS \([0-9]*\) [A-Z a-z = 0-9 .]*/\1/p' *.dimacs.res

The file argument here expands to a list of all files with the suffix
`.dimacs.res`. The output is then a list of numbers, each a number of colours
used in a certain colouring. We want to total all of these numbers. There
are several different ways of summing numbers in a file. One convenient approach
combines the `paste` and `bc` commands. The following pipeline will find all
colouring numbers for a collection of files and return the total number of
colours used.

    sed -n 's/CLRS \([0-9]*\) [A-Z a-z = 0-9 .]*/\1/p' *.dimacs.res\
    | paste -s -d"+"\
    | bc

## Experiment Results

We put all of the steps together into a simulation. This simulation went through
all graphs of order at most 8 and computed the total number of colours used by
the greedy algorithm using four different orderings. The results are given in
the table below.

| ordering          | order `$$\leq 7$$` | order `$$\leq 8$$` |
|-------------------|:------------------:|:------------------:|
| in order          |        3732        |       42603        |
| random order      |        3906        |       44770        |
| descending degree |        3616        |       41102        |
| ascending degree  |        3965        |       42181        |

As before we can see that descending degree is the best way to go, at least for
graphs of order at most 8.

## Source Code

{{% gist "MHenderson" "0bc559d87514a4e482e7" %}}
