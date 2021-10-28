---
title: "(WIP) The Petersen Graph in Diversity"
description: "Discover the Petersen graph in myriad ways."
author: Matthew Henderson
date: '2014-10-03'
slug: petersen-graph
categories:
  - graph-theory
tags:
  - geng
  - awk
  - pickg
  - python
draft: true
references:
- id: westerReviewCASMathematical1994
  abstract: >-
    Computer algebra systems (CASs) have become an important computational tool
    in the last decade. General purpose CASs, which are designed to solve a wide
    variety of problems, have gained special prominence. In this paper, the
    capabilities of six major general purpose CASs (Axiom, Derive, Macsyma,
    Maple, Mathematica and Reduce) are reviewed on 131 short problems covering a
    broad range of (primarily) symbolic mathematics. A demo was developed for
    each CAS, run and the results evaluated. Problems were graded in terms of
    whether it was easy or difficult or possible to produce an answer and if an
    answer was produced, whether it was correct. It is the author's hope that
    this review will encourage the development of a comprehensive CAS test
    suite.  Presented below is a summary of 131 mathematical problems (primarily
    symbolic) that were given to the six general purpose computer algebra
    systems (CASs) listed in Table 1. The CAS versions tested were those that
    were available to the author and wer...
  author:
    - family: Wester
      given: Michael
  container-title: Computer Algebra Nederland Nieuwsbrief
  issued:
    - year: 1994
  page: 41–48
  source: CiteSeer
  title: A Review of CAS Mathematical Capabilities
  type: article-journal
  volume: '13'
- id: holtonPetersenGraph1993
  abstract: >-
    The Petersen graph occupies an important position in the development of
    several areas of modern graph theory because it often appears as a
    counter-example to important conjectures. In this account, the authors
    examine those areas, using the prominent role of the Petersen graph as a
    unifying feature. Topics covered include: vertex and edge colourability
    (including snarks), factors, flows, projective geometry, cages,
    hypohamiltonian graphs, and 'symmetry' properties such as distance
    transitivity. The final chapter contains a pot-pourri of other topics in
    which the Petersen graph has played its part. Undergraduate students will be
    able to profit from reading this book as the prerequisites are few; thus it
    could be used for a second course in graph theory. On the other hand, the
    authors have also included a number of unsolved problems as well as topics
    of recent study. Thus it will also be useful as a reference for graph
    theorists.
  accessed:
    - year: 2021
      month: 7
      day: 30
  author:
    - family: Holton
      given: D. A.
    - family: Sheehan
      given: J.
  container-title: Cambridge Core
  DOI: 10.1017/CBO9780511662058
  ISBN: 9780521435949 9780511662058
  issued:
    - year: 1993
      month: 4
  language: en
  publisher: Cambridge University Press
  title: The Petersen Graph
  type: webpage
  URL: >-
    https://www.cambridge.org/core/books/petersen-graph/ACD2C8C835C98565C6365E93FF29E4EC
- id: petersen98
  author:
    - family: Petersen
      given: J.
  container-title: L'Intermédiaire des Mathématiciens
  issued:
    - year: 1898
  page: 225-227
  title: Sur le théorème de Tait
  type: article-journal
  volume: '5'
---

In
Wester (1994)
an influential list of 123 problems that a
reasonable computer algebra system (CAS) should be able to solve is presented.
In this post we begin creating a similar list of problems in graph theory that a
reasonable graph analysis system (GAS) ought to be able to solve.

The inspiration for this list comes from Chapter 9 of
Holton and Sheehan (1993)
from where the title of this post is
borrowed. That chapter presents many different definitions of the Petersen
graph. The aim of this post is to implement as many of them as possible. The
post will be updated as more implementations are discovered.

## The Petersen Graph

The Petersen graph gets its name from its appearance in the paper
Petersen (1898)
of J. Petersen as a counterexample to Tait’s claim that
‘every bridgeless cubic graph is 1-factorable.’ This was not the first time the
Petersen graph appeared in the literature of graph theory and far from the last.
Since then it has appeared in a great many publications, often as a
counterexample to a new conjecture.

Definitions of the Petersen graph arise in different ways. As direct
constructions (for example by identifying antipodal points in the graph of the
dodecahedron) or indirectly as one of a class of graphs satisfying certain
properties (one of the bridgeless cubic graphs which are not 1-factorable).

In this post we being to collect as many different definitions as possible and
give implementations of constructions or filters based on list of properties.
The purpose of this is several-fold

-   to initiate an effort to formulate a list of problems that a reasonable GAS
    ought to be able to solve,
-   to motivate the development of tools for graph analysis on the command-line,
-   to create test cases for a collection of graph data.

The third of these motivations is something that we will return to in future
posts.

Below are two lists. The latter is a collection of properties of the
Petersen graph. The first is a list of definitions. To avoid repetition, if a
single property defines the Petersen graph uniquely then it appears in the
first list only.

In both lists `\(C(n)\)` denotes the set of connected cubic graphs of order
`\(n\)`.

The canonical *graph6* encoding of the Petersen graph is `IsP@OkWHG`.

## The Definition List

1.  The complement of the line graph of `\(K_{5}\)`.
    -   ``` bash
            $ geng -q -d4D4 5 | linegraphg -q | complg -q | labelg -q
            IsP@OkWHG
        ```
2.  The unique Moore graph of order 10.
    -   ``` bash
            $ geng -qc 10 | moore.py | labelg -q
            IsP@OkWHG
        ```
3.  The only graph in `\(C(10)\)` with 120 automorphisms.
    -   ``` bash
            $ geng -qc 10 -d3D3 | pickg -q -a120 | labelg -q
            IsP@OkWHG
        ```
4.  The only graph in $C(10)$ with girth 5.
    -   ``` bash
            $ paste <(geng -qc 10 -d3D3) <(geng -qc 10 -d3D3 | girth.py)\
             | awk '{ if ($2==5) print $1 }'\
             | labelg -q
            IsP@OkWHG
        ```
5.  The only graph in `\(C(10)\)` with diameter 2.
    -   ``` bash
            $ paste <(geng -qc 10 -d3D3) <(geng -qc 10 -d3D3 | diameter.py)\
             | awk '{ if ($2==2) print $1 }'\
             | labelg -q
            IsP@OkWHG
        ```
6.  The Kneser graph $K_{5,2}$.
    -   ``` bash
            $ maxima --very-quiet --batch-string="\
               load(graphs)$
               s : powerset({`seq 1 5 | paste -s -d,`}, 2)$
               g : make_graph(s, disjointp)$
               graph6_encode(g);
              "\
              | tail -n 1\
              | tr -d ' \t\r\f'\
              | labelg -q
              IsP@OkWHG
        ```
7.  The Odd graph `\(O(3)\)`.
8.  The Moore graph with degree 3 and girth 5.
9.  The graph in `\(C(10)\)` with the most spanning trees (2000).
10. The smallest bridgeless cubic graph with no 3-edge-colouring.
11. The only bridgeless graph in `\(C(10)\)` with chromatic number 4.
12. The only non-hamiltonian graph in `\(C(10)\)`.
13. The graph obtained from the dodecahedron graph by identifying antipodal
    vertices.
14. The subgraph of `\(G_{1} = \overline{T(7)}\)` induced by `\(N(12)\)`.
15. The graph whose vertices are the 21 transpositions in `\(S_{7}\)` whose edges
    join vertices that represent commuting transpositions.
16. One of only twelve connected cubic graphs with integral spectra.
17. Every orientation has diameter at least 6.
18. Every strongly connected orientation has a directed cycle of length 5.
19. Is 2-connected and all dominating cycles have length `\(<n\)`.
20. Is 1-tough `\(\alpha \leq k + 1\)`, `\(k \geq 3\)` and non-hamiltonian.
21. Pancyclic and has no cycle of length 4, 5, 6 or 7 or one of two other graphs.
22. The complement of the Johnson graph `\(J(5,2)\)`.
23. As a uniform subset graph with parameters `\((5,2,0)\)` or `\((5, 3, 1)\)`.
24. As the projective planar dual of `\(K_{6}\)`.
25. The unique generalised Petersen graph with `\(\chi = 4\)`.

## The Properties List

-   name: Petersen Graph
-   order: 10
-   size: 15
-   chromatic-number: 3
-   chromatic-index: 4
-   diameter: 2
-   edge-connectivity: 4
-   girth: 5
-   independence-number: 4
-   maximum-degree: 3
-   radius: 2
-   spectrum: `\(\{3, 1^{5}, -2^{4}\}\)`
-   vertex-connectivity: 3

## Future Directions

As of 3/10/14 there 5 of 25 definitions with full implementation. The property
list contains 8 items.

Plans for the immediate future are to complete the property list and to
incorporate the property list data into the testing system of the
graphs-collection project.

Beyond this, the medium-term goal is to extend the list of definitions
and provide implementations where possible.

In the long-term we hope to extend and generalise the list to devise a list of
problems that a GAS ought to be able to solve in analogy with Wester’s list of
computer algebra problems.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-holtonPetersenGraph1993" class="csl-entry">

Holton, D. A., and J. Sheehan. 1993. “The Petersen Graph.” Cambridge Core. Cambridge University Press. April 1993. <https://doi.org/10.1017/CBO9780511662058>.

</div>

<div id="ref-petersen98" class="csl-entry">

Petersen, J. 1898. “Sur Le Théorème de Tait.” *L’Intermédiaire Des Mathématiciens* 5: 225–27.

</div>

<div id="ref-westerReviewCASMathematical1994" class="csl-entry">

Wester, Michael. 1994. “A Review of CAS Mathematical Capabilities.” *Computer Algebra Nederland Nieuwsbrief* 13: 41–48.

</div>

</div>