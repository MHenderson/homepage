---
title: "(WIP) Colouring Small Graphs: Update"
description: "Reproducing the distribution of chromatic numbers for small graphs."
author: Matthew Henderson
date: '2014-08-08'
slug: colouring-small-graphs-update
categories:
  - graph-colouring
tags:
  - chromatic
  - gtools
  - drake
  - coreutils
draft: true
references:
- id: haggardComputingTuttePolynomials2010
  abstract: >-
    The Tutte polynomial of a graph, also known as the partition function of the
    q-state Potts model is a 2-variable polynomial graph invariant of
    considerable importance in both combinatorics and statistical physics. It
    contains several other polynomial invariants, such as the chromatic
    polynomial and flow polynomial as partial evaluations, and various numerical
    invariants such as the number of spanning trees as complete evaluations.
    However despite its ubiquity, there are no widely available effective
    computational tools able to compute the Tutte polynomial of a general graph
    of reasonable size. In this article we describe the implementation of a
    program that exploits isomorphisms in the computation tree to extend the
    range of graphs for which it is feasible to compute their Tutte polynomials,
    and we demonstrate the utility of the program by finding counterexamples to
    a conjecture of Welsh on the location of the real flow roots of a graph.
  accessed:
    - year: 2021
      month: 7
      day: 29
  author:
    - family: Haggard
      given: Gary
    - family: Pearce
      given: David J.
    - family: Royle
      given: Gordon
  container-title: ACM Transactions on Mathematical Software
  container-title-short: ACM Trans. Math. Softw.
  DOI: 10.1145/1824801.1824802
  ISSN: 0098-3500
  issue: '3'
  issued:
    - year: 2010
      month: 9
      day: 1
  page: 24:1–24:17
  source: September 2010
  title: Computing Tutte Polynomials
  type: article-journal
  URL: https://doi.org/10.1145/1824801.1824802
  volume: '37'
- id: mckayPracticalGraphIsomorphism2014
  abstract: >-
    We report the current state of the graph isomorphism problem from the
    practical point of view. After describing the general principles of the
    refinement-individualization paradigm and pro ving its validity, we explain
    how it is implemented in several of the key implementations. In particular,
    we bring the description of the best known program nauty up to date and
    describe an innovative approach called Traces that outperforms the
    competitors for many difficult graph classes. Detailed comparisons against
    saucy, Bliss and conauto are presented.
  accessed:
    - year: 2021
      month: 7
      day: 29
  author:
    - family: McKay
      given: Brendan D.
    - family: Piperno
      given: Adolfo
  container-title: Journal of Symbolic Computation
  container-title-short: Journal of Symbolic Computation
  DOI: 10.1016/j.jsc.2013.09.003
  ISSN: 0747-7171
  issued:
    - year: 2014
      month: 1
      day: 1
  language: en
  page: 94-112
  source: ScienceDirect
  title: Practical graph isomorphism, II
  type: article-journal
  URL: https://www.sciencedirect.com/science/article/pii/S0747717113001193
  volume: '60'
---

In
[Colouring Small Graphs](/post/colouring-small-graphs)
we attempted to reproduce Gordon Royle’s data on the distribution of
[chromatic numbers of small graphs](http://staffhome.ecm.uwa.edu.au/~00013890/remote/graphs#cols).
We were partially
successful, reproducing his results for graphs of order at most seven using
the `chromatic` shell script built on the
[implementation](http://homepages.ecs.vuw.ac.nz/~djp/tutte/)
of the Tutte
polynomial by
Haggard, Pearce, and Royle (2010)
.

Our simulation, however, ran into difficulty with graphs of order eight. We
found a distribution of chromatic numbers different from Royle’s. As we
had been successful with smaller orders it seemed most likely that we had
some issue with corrupt data. The
[small graph data](http://cs.anu.edu.au/~bdm/data/graphs.html)
we started with
comes from a reliable source and therefore the corruption was probably
introduced by our ad-hoc methods of translating formats.

Our format conversion had two steps. We started with McKay’s *graph6* format
data, first converting this into *Dimacs* format. Then we took the *Dimacs*
format data and converted it into Graphviz *DOT* format. The reason behind the
two step approach was that we had previously implemented *Dimacs* to *DOT*
conversion in *Sed*. Since then, however, we have discovered that McKay’s
*gtools* collection of programs from the
[nauty](http://cs.anu.edu.au/~bdm/nauty)
McKay and Piperno (2014)
project already implements conversion to *DOT* format.

The second conversion step involved splitting one file containing one graph
per line into a folder of files with one graph per file. We had written an AWK
program to do this but have since discovered the *csplit* program in the GNU
Coreutils package which is specifically for this purpose.

Using these more appropriate tools has solved the problem with our reproduction
of Royle’s colouring data and in this post we reproduce his table of chromatic
numbers of connected graphs as far as graphs of order eight.

## Overview

We start with Brendan McKay’s
[small graph data](http://cs.anu.edu.au/~bdm/data/graphs.html)
files in *graph6*
format with one graph per line and one file per order. We consider only
connected graphs.

The simulation itself aims to reproduce the
[table of chromatic numbers](http://staffhome.ecm.uwa.edu.au/~00013890/remote/graphs#cols)
of small graphs of Gordon Royle.

To reproduce the desired output we follow three steps:

1.  Convert *graph6* data into *DOT* data.
2.  Process *DOT* data. Compute the chromatic number of every graph and store
    chromatic numbers in per-order results files.
3.  Collate the per-order distributions into a table.

In previous posts we have tried, as far as possible, to emphasise the Unix
pipeline approach to presenting a workflow. An advantage of this approach
is a pipeline can be cut from the blog and pasted into a console to reproduce
our simulation. A secondary benefit is that it encourages us to adhere to Unix
philosophies like having small, orthogonal programs that can be combined
together into pipelines to achieve more complicated tasks. We have also used
Make as a more powerful language for expressing computational workflows.
In this post we are going to use a Make-like tool
[Drake](https://github.com/Factual/drake)
which is
designed specifically for the task of expressing and automating a computational
workflow. *Drake* is not part of *GNU* but it is free software.

In the rest of this post we describe each of the three steps above in more
detail. At the end of this post is a Drakefile which can be used to reproduce
the second two steps of our simulation. At the point of writing the data
conversion step is embedded in a Makefile inside the
[graphs-collection](http://mhenderson.github.io/graphs-collection/)
project.

## Convert Graph Data

This is much easier than before. The `listg` program in the *gtools* collection
of programs can output graphs in *DOT* format by using the `-y` switch.

    $ curl -s http://cs.anu.edu.au/~bdm/data/graph4c.g6 | listg -y
    graph G1 {
    0--3;
    1--3;
    2--3;
    }
    graph G2 {
    0--2;
    0--3;
    1--3;
    }
    graph G3 {
    0--2;
    0--3;
    1--3;
    2--3;
    }
    graph G4 {
    0--2;
    0--3;
    1--2;
    1--3;
    }
    graph G5 {
    0--2;
    0--3;
    1--2;
    1--3;
    2--3;
    }
    graph G6 {
    0--1;
    0--2;
    0--3;
    1--2;
    1--3;
    2--3;
    }

Now we split this output across several files using *csplit*.

    curl http://cs.anu.edu.au/~bdm/data/graph4c.g6
    | listg -y
    | csplit -sz -b '%d.gv' -f '' - '/^graph.*/' '{*}'

The result of this pipeline are six files `0.gv` through `5.gv` containing
the six graphs above.

Options for *csplit* are explained in the
[csplit manpage](http://man7.org/linux/man-pages/man1/csplit.1.html)
and in more detail in the
\[csplit documentation\](http://www.gnu.org/software/coreutils/manual/html\_node/csplit-invocation.html.
The relevant options
in this case are

-   `-s` – Quiet output. Otherwise csplit prints out the size of each output file.
-   `-z` – Remove empty output files.
-   `-b` – This option has an argument describing the suffix format.
-   `-f` – Prefix format. We have chosen an empty prefix. The default is xx.

The hyphen in the option list represents standard input. After that comes two
patterns. The first is used to decide where to split. In this case we begin on
any line that begins with the string `graph`. The second `'{*}'` pattern tells
*csplit* to repeat the splitting as many times as possible.

## Process Graph Data

At this point we have a collection of files in *DOT* format representing all
connected graphs of a certain order. For each graph we compute the chromatic
number, using the `chromatic` script, and append the result to a file of
chromatic numbers of all graphs of the same order.

In this section we describe the workflow using *Drake*, a *Make*-like program
designed for describing and automating computational workflows.

*Drake* is used by writing a `Drakefile`. A `Drakefile` bears the same relation
to *Drake* that a `Makefile` bears to *Make*. It contains a list of rules which
describe how to make an output file from an input file, collection of input
files or folder.

For example, if `4c_gv` is a folder containing all connected graphs of order
four then a *Drake* rule which generates a file `4c_chromatic.txt` containing
the chromatic numbers of all graphs in the folder looks like this.

    4c_chromatic.txt <- 4c_gv
      for graph in $INPUTS/*;
      do
       chromatic ${graph} >> $OUTPUT
      done

The assignment of `4c.gv` to the variable `INPUTS` and `4c_chromatic.txt` to the
variable `OUTPUT` is done automatically by *Drake*.

The body of this rule is something that can be used in the rules for graphs
of other orders. So we create a method, `compute_chromatic`, and assign the
method to rules using the `[method: compute_chromatic]` rule option.

    compute_chromatic()
      for graph in $INPUTS/*;
      do
       chromatic ${graph} >> $OUTPUT
      done

    4c_chromatic.txt <- 4c_gv [method:compute_chromatic]

## Analyse Results

The first stage of analysis is to take all the generated files of chromatic
numbers and create new files containing the distribution of chromatic numbers.
These files will contain two tab-separated columns. The first column being a
list of possible chromatic numbers and the second being a count of graphs
having that chromatic number.

For this purpose a *Drake* method `make_distribution` runs through a sequence of
possible chromatic numbers. For each value `grep` counts the occurrences in the
input file of that value and appends the result to an output file. The *GNU
Coreutils* `cut` and `paste` are used, along with the arbitrary precision
calculator language `bc`, to compute a total count for each chromatic number
which is appended to the end of the output file.

    make_distribution()
      for j in `seq 1 8`
      do
       echo -e $j'\t' `grep -c $j $INPUT` >> $OUTPUT
      done
      echo -e Total:'\t' `cut -f 2 $OUTPUT | paste -sd+ | bc` >> $OUTPUT

    4c_distribution.txt <- 4c_chromatic.txt [method:make_distribution]

The second task is to take all of the distribution files (one for each order)
and build a table to match the Royle table. To do this a *Drake* rule takes
the distribution files as input and produces, as output, a file
`table.txt` containing the table. The work is done by *GNU Coreutils* `paste`
and `cut` which are piped together to join all distribution files into
a single file and then select the relevant columns to produce the final
table.

    table.txt <- 2c_distribution.txt,
                 3c_distribution.txt,
                 4c_distribution.txt,
                 5c_distribution.txt,
                 6c_distribution.txt,
                 7c_distribution.txt,
                 8c_distribution.txt
      paste $INPUTS | cut -f 1,2,4,6,8,10,12,14 > $OUTPUT

The output of this rule is a file `table.txt` which contains the following
table.

|                 | `$$n = 2$$` |   3 |   4 |   5 |   6 |   7 |    8 |    9 |
|:---------------:|:-----------:|----:|----:|----:|----:|----:|-----:|-----:|
| `$$\chi =  2$$` |      0      |   1 |   3 |   5 |  10 |  15 |   26 |   37 |
|        3        |      0      |   1 |   5 |  14 |  46 | 123 |  350 |  772 |
|        4        |      0      |   0 |   0 |  10 |  55 | 258 |  749 | 1476 |
|        5        |      0      |   0 |   0 |   2 |  23 | 104 |  305 |  568 |
|        6        |      0      |   0 |   0 |   0 |   0 |  18 |   57 |  125 |
|        7        |      0      |   0 |   0 |   0 |   0 |   0 |    9 |   22 |
|        8        |      0      |   0 |   0 |   0 |   0 |   0 |    0 |    4 |
|        9        |      0      |   0 |   0 |   0 |   0 |   0 |    0 |    0 |
|     Total:      |      0      |   2 |   8 |  31 | 134 | 518 | 1496 | 3004 |

This table agrees with Royle’s as far as it goes. As yet we haven’t been able
to extend our results to higher order because our brute-force-ish approach is
too slow to process all 261080 connected graphs of order 9 in a reasonable
amount of time. The good news, though, is that we have left plenty of room for
improvement to the speed of our code and our approach should be ripe for
parallelisation. So there is a good chance that in the future we can extend
our table to match Royle’s at least as far as order 9.

## Source Code

{{% gist "MHenderson" "aa494aeee9f52a6fb50d" "Drakefile" %}}

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-haggardComputingTuttePolynomials2010" class="csl-entry">

Haggard, Gary, David J. Pearce, and Gordon Royle. 2010. “Computing Tutte Polynomials.” *ACM Transactions on Mathematical Software* 37 (3): 24:1–17. <https://doi.org/10.1145/1824801.1824802>.

</div>

<div id="ref-mckayPracticalGraphIsomorphism2014" class="csl-entry">

McKay, Brendan D., and Adolfo Piperno. 2014. “Practical Graph Isomorphism, II.” *Journal of Symbolic Computation* 60 (January): 94–112. <https://doi.org/10.1016/j.jsc.2013.09.003>.

</div>

</div>
