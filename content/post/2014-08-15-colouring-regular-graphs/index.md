---
title: "(WIP) Colouring Small Regular Graphs"
description: "Chromatic numbers of small, regular graphs."
author: Matthew Henderson
date: '2014-08-15'
slug: colouring-regular-graphs
categories:
  - graph-colouring
tags:
  - nauty
  - drake
  - chromatic-number
  - coreutils
draft: true
references:
- id: RegularGraphsPrescribed
  accessed:
    - year: 2021
      month: 7
      day: 29
  title: >-
    Regular graphs with prescribed chromatic number - Caccetta - 1990 - Journal
    of Graph Theory - Wiley Online Library
  type: webpage
  URL: https://onlinelibrary.wiley.com/doi/10.1002/jgt.3190140107
---

In this post we present two tables of data on chromatic numbers of
\[regular graphs\]\[def:regular-graph\].
Both tables give chromatic numbers of
simple graphs on at most ten vertices. The first table shows the distribution of
chromatic numbers over all regular simple graphs on at most ten vertices. The
second table gives the distribution of chromatic numbers over all connected
regular simple graphs on at most ten vertices. In this post we describe how this
data was generated.

## Overview

The method used to generate the tables is the same method using in
[Colouring Small Graphs](/post/2014/07/25/colouring-small-graphs)
except that we
use *geng* from the *gtools* collection of programs from the
[*nauty*](http://cs.anu.edu.au/~bdm/nauty)
package of Brendan McKay to generate the graph data, rather than download it
from McKay’s webpage. This small change has the benefit that we can now run our
simulation without an internet connection. The potential disadvantage of the
extra dependency on *nauty* is not a new disadvantage because we were already
using the *listg* program from *gtools* to convert data from *graph6* to *DOT*
format.

As the method we use is almost identical to the method of
[Colouring Small Graphs](/post/2014/07/25/colouring-small-graphs)
we don’t consider all of the details again here. Instead, we will describe only
the differences. These are

-   using *geng* to generate regular graphs of order at most 10,
-   splitting *DOT* data across multiple files using a [Drake](https://github.com/Factual/drake) rule,
-   taking a little extra care to collect chromatic numbers using *grep*.

Each of these small changes is discussed in detail in the following three
sections. After that, we present the data itself. The source code for the entire
simulation can be downloaded as a Drakefile at the bottom of the post.

## Generating Regular Graphs

The
[small graph data](http://cs.anu.edu.au/~bdm/data/graphs.html)
available on Brendan McKay’s webpage can also be
generated using the *geng* program.

The most basic usage pattern for *geng* is `geng n` where `n` is the order of
graphs to be generated. The output is a listing of all graphs of order `n` with
one graph per line in *graph6* format.

    $ geng 2
    >A geng -d0D1 n=2 e=0-1
    A?
    A_
    >Z 2 graphs generated in 0.00 sec

Notice that the `geng 2` command was expanded automatically to `geng -d0D1 n=2 e=0-1`. The first and last lines here can be suppressed using the `-q` switch.

    $ geng -q 2
    A?
    A_

Now this can be piped into `listg -y` (we can also do the piping before
suppressing the auxiliary data) to convert the output graph data to *DOT*
format.

    $ geng -q 2 | listg -y
    graph G1 {
    }
    graph G2 {
    0--1;
    }

The expanded call to `geng` which was generated automatically above is the clue
to how we can use `geng` to generate regular graphs. Optional switches of the
form `-d#` and `-D#` allow bounds on, respectively, the minimum and maximum
degree to be specified. `-d0D1` says that the minimum degree should be zero and
the maximum degree should be 1. So, for example, to generate all 1-regular
graphs on three vertices:

    $ geng -q -d1D1 3
    >E geng: impossible mine,maxe,mindeg,maxdeg values
    >E Usage: geng [-cCmtfbd#D#] [-uygsnh] [-lvq]
                  [-x#X#] n [mine[:maxe]] [res/mod] [file]
       Use geng -help to see more detailed instructions.

The error message here is no surprise. After all, there are no 1-regular graphs
of order three. This reminds us that for regular graphs of odd degree we must
have an even number of vertices (because the total degree `\(2m\)` of a graph with
`\(m\)` edges is even).

    $ geng -q -d1D1 4 | listg -y
    graph G1 {
    0--2;
    1--3;
    }

In this case there is only one graph because *geng* only generates
non-isomorphic graphs.

The only other consideration we must be aware of is that if a graph is
`\(k\)`-regular then, because `\(\Delta(G) \leq n - 1\)`, it must have at least
`\(k + 1\)` vertices. So, for example, the generate all 3-regular graphs on at
most ten vertices in *graph6* format:

    $ seq 4 2 10 | xargs -L1 geng -q -d3D3
    C~
    EFz_
    EUxo
    G?zTb_
    GCrb`o
    GCZJd_
    GCXmd_
    GCY^B_
    GQhTQg
    I?BeeOwM?
    I?Bcu`gM?
    I?bFB_wF?
    I?bEHow[?
    I?`bfAWF?
    I?`cu`oJ?
    I?`cspoX?
    I?`bM_we?
    I?`cm`gM?
    I?`cmPoM?
    I?`amQoM?
    I?`c]`oM?
    I?aKZ`o[?
    ICOfBaKF?
    ICOf@pSb?
    ICOef?kF?
    ICOedPKL?
    ICOedO[X?
    ICQRD_kQ_
    ICQRD_iR?
    ICQRChgI_

Piping this output (not shown) into `listg -y` then generates a listing of the
same graphs in *DOT* format.

## Splitting Graph Data

As before we split the resulting *DOT* format graph data across a folder of
multiple files, one per graph. In the last post we did this outside of the
Drakefile. Now, because we are generating all the graph data we use, we are
forced to do the splitting with Drake.

This involves a *Drake* method `split()`

    split()
      mkdir -p $OUTPUT
      csplit -sz -b '%d.gv' -f$OUTPUT/ $INPUT '/^graph.*/' '{*}'

and rules for each degree. For example, to generate the folder
`data/1r_gv_split` from the *DOT* file of 1-regular graphs `data/1r_gv`:

    data/1r_gv_split <- data/1r_gv [method:split]

The *csplit* invocation is exactly the same as before. The only difference in
the method is that before splitting we create the output folder, if it doesn’t
already exist.

## Collecting Chromatic Numbers

With the graph data now built we iterate as before over all graphs, collecting
their chromatic numbers. However, now because we are considering graphs of
orders up to 10 there is a possibility of chromatic number 10. This means that
we have to be a little bit more careful when it comes to using *grep* to make
sure that we count occurrences of chromatic numbers correctly. Where we had been
using

    grep -c $j $INPUT

now we use:

    grep -Fcx $j $INPUT

The `-F` switch here ensures that `$j` is considered as an entire string for
matching. So, for example, if `$j=10` the *grep* searches for occurrences of the
sequence `10` not occurrences of `1` or `0`. The `-x` switch ensures,
additionally, that only exact matches are counted. For example, if `10` occurs
in a longer string, `110` say, then *grep* won’t count this.

## Results

With all of the above considerations we found the following data for regular
simple graphs on at most 10 vertices, including disconnected graphs.

|             | `$$\chi = 1$$` |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |
|:-----------:|:--------------:|----:|----:|----:|----:|----:|----:|----:|----:|
| `$$k = 1$$` |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |
|      2      |       5        |   6 |   4 |   2 |   1 |   0 |   0 |   0 |   0 |
|      3      |       0        |  13 |  22 |  42 |   6 |   2 |   0 |   0 |   0 |
|      4      |       0        |   0 |   4 |  40 |  53 |  11 |   1 |   0 |   0 |
|      5      |       0        |   0 |   0 |   2 |   3 |  13 |   3 |   1 |   0 |
|      6      |       0        |   0 |   0 |   0 |   1 |   0 |   1 |   0 |   0 |
|      7      |       0        |   0 |   0 |   0 |   0 |   1 |   0 |   0 |   0 |
|      8      |       0        |   0 |   0 |   0 |   0 |   0 |   1 |   0 |   0 |
|      9      |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   1 |   0 |
|     10      |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   1 |
|   Total:    |       5        |  19 |  30 |  86 |  64 |  27 |   6 |   2 |   1 |

The data for connected regular simple graphs on at most 10 vertices is as
follows:

|             | `$$\chi = 1$$` |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |
|:-----------:|:--------------:|----:|----:|----:|----:|----:|----:|----:|----:|
| `$$k = 1$$` |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   0 |
|      2      |       1        |   4 |   4 |   2 |   1 |   0 |   0 |   0 |   0 |
|      3      |       0        |   4 |  22 |  42 |   6 |   2 |   0 |   0 |   0 |
|      4      |       0        |   0 |   1 |  40 |  53 |  11 |   1 |   0 |   0 |
|      5      |       0        |   0 |   0 |   1 |   3 |  13 |   3 |   1 |   0 |
|      6      |       0        |   0 |   0 |   0 |   1 |   0 |   1 |   0 |   0 |
|      7      |       0        |   0 |   0 |   0 |   0 |   1 |   0 |   0 |   0 |
|      8      |       0        |   0 |   0 |   0 |   0 |   0 |   1 |   0 |   0 |
|      9      |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   1 |   0 |
|     10      |       0        |   0 |   0 |   0 |   0 |   0 |   0 |   0 |   1 |
|   Total:    |       1        |   8 |  27 |  85 |  64 |  27 |   6 |   2 |   1 |

## Conclusions

At this point we haven’t given much (any?) consideration about the veracity of
the above data. There is a certain degree of confidence in using a method which
has been used before to generate chromatic numbers of graphs that can be
verified against an existing, independent computation.

We can at least be fairly confident about the generated graph data, for a couple
of reasons. Firstly, to generate the data we used a fairly trivial application
of reliable graph generating software. Additionally, at least in the connected
case, we can compare at least the total number of graphs of each degree against
a
[independent computation](http://www.mathe2.uni-bayreuth.de/markus/reggraphs.html#CRG)
of Markus Meringer.

In the future we will revisit the above data and consider how we might add some
verification steps. There are bounds for the chromatic number of regular graphs
and results like the following one of
“Regular Graphs with Prescribed Chromatic Number - Caccetta - 1990 - Journal of Graph Theory - Wiley Online Library” (n.d.)
have some potential in this regard.

**Theorem**

If `\(k > 1\)`, then for every `\(n \geq \lceil\frac{5k}{3}\rceil\)` there is a
connected, regular, `\(k\)`-chromatic graph on `\(n\)` vertices.

One approach would be the generalise our method to graphs of greater order. The
Drakefile, as it stands, is not straightforward to extend in this regard.

## Source Code

{{% gist "MHenderson" "b4cd8612ac8e876608a4" "Drakefile" %}}

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-RegularGraphsPrescribed" class="csl-entry">

“Regular Graphs with Prescribed Chromatic Number - Caccetta - 1990 - Journal of Graph Theory - Wiley Online Library.” n.d. Accessed July 29, 2021. <https://onlinelibrary.wiley.com/doi/10.1002/jgt.3190140107>.

</div>

</div>
