---
title: "Greedy Edge Colouring of Small Graphs"
author: Matthew Henderson
date: '2014-09-26'
description: The efficacy of a greedy edge-colouring algorithm.
slug: greedy-small
categories:
  - graph-theory
tags:
  - bash
  - edge-colouring
  - networkx
  - python
  - matplotlib
references:
- id: chartrandChromaticGraphTheory2008
  abstract: >-
    Beginning with the origin of the four color problem in 1852, the field of
    graph colorings has developed into one of the most popular areas of graph
    theory. Introducing graph theory with a coloring theme, Chromatic Graph
    Theory explores connections between major topics in graph theory and graph
    colorings as well as emerging topics. This self-contain
  author:
    - family: Chartrand
      given: Gary
    - family: Zhang
      given: Ping
  ISBN: 978-1-58488-801-7
  issued:
    - year: 2008
      month: 9
      day: 22
  language: en
  number-of-pages: '499'
  publisher: CRC Press
  source: Google Books
  title: Chromatic Graph Theory
  type: book
---

In seveal earlier posts we looked at greedy vertex-colouring of small graphs. As
we saw, a greedy approach to vertex-colouring is quite successful in so far as
it uses at most `\(\Delta(G) + 1\)` colours to colour any graph `\(G\)`.

It is easy to modify the greedy method to colour the edges of a graph. However,
we cannot guarantee that the number of colours used will be as few as
`\(\Delta(G) + 1\)`. The best that we can guarantee with the simplest greedy
approach to edge-colouring is no more than `\(2\Delta(G) - 1\)` colours.

It’s not difficult to see why this is, for suppose that we have coloured some
edges of the graph and come to colour edge `\(e = uv\)`. There might be as many as
`\(\Delta(G) - 1\)` colours on edges incident with `\(u\)` and the same amount on
edges incident with `\(v\)`. In the worst case, all of these `\(2\Delta(G) - 2\)`
colours might be different and so we need at least `\(2\Delta(G) - 1\)` colours in
our palette to be certain, without recolouring, to have a colour available for
edge `\(e\)`.

In this post we introduce a NetworkX-based implementation of greedy
edge-colouring for graphs in *graph6* format. Using this implementation we
investigate the average case performance on all non-isomorphic, connected simple
graphs of at most nine vertices. It turns out that, on average, the greedy
edge-colouring method uses many fewer colours than the worst case of
`\(2\Delta(G) - 1\)`.

As we will discuss, the theory of edge-colouring suggests that with large sets
of simple graphs we can get close, on average, to the best case of `\(\Delta(G)\)`
colours.

## Greedy Edge-Colouring with NetworkX

The core of our implementation is a function that visits every edge of a graph
and assigns a colour to each edge according to a parametrised colour choice
strategy.

``` python
def edge_colouring(G, choice = choice_greedy):
    max_degree = max(G.degree().values())
    palette = range(0, 2*max_degree)
    for e in G.edges():
        colour_edge(G, e, choice(G, e, palette))
```

This function allows for some flexibility in the method used to choose the
colour assigned to a certain edge. Of course, it lacks flexibility in certain
other respects. For example, both the order in which edges are visited and the
palette of colours are fixed.

Everything in the implementation is either Python or NetworkX, except for the
`colour_edge(G, e, c)` and `choice(G, e, p)` functions. The former simply
applies colour `c` to edge `e` in graph `G`. The latter, a function parameter
that can be specified to implement different colouring strategies, decides the
colour to be used.

For greedy colouring the choice strategy is plain enough. For edge `\(e = uv\)`
in graph `\(G\)` we choose the first colour from a palette of colours which is
not used on edges incident with either vertex `\(u\)` or vertex `\(v\)`. The
implementation, below, is made especially simple by Python’s `Set`s.

``` python
def choice_greedy(G, e, palette):
    used_colours = used_at(G, e[0]).union(used_at(G, e[1]))
    available_colours = set(palette).difference(used_colours)
    return available_colours.pop()
```

Here `used_at(G, u)` is a function that returns a `Set` of all colours used on
edges incident with `u` in `G`. So, via the `union` operation on `Sets`,
`used_colours` becomes the set of colours used on edges incident with
end-vertices of `e`. The returned colours is then the colour on the top of
`available_colours`, the set difference of `palette` and `used_colours`.

## Edge-Colouring Small Graphs

The implementation described in the previous section has been put into a script
that processes graphs in *graph6* format and returns, not the edge-colouring,
but the number of colours used. For example, the number of colours used in a
greedy edge-colouring of the Petersen graph is four:

``` bash
$ echo ICOf@pSb? | edge_colouring.py
4
```

As in earlier posts on vertex-colouring we now consider the set of all
non-isomorphic, connected, simple graphs and study the average case performance
of our colouring method on this set. For vertex-colouring, parallel edges have
no effect on the chromatic number and thus the set of simple graphs is the right
set of graphs to consider. For edge-colouring we ought to look at parallel edges
and thus the set of multigraphs because parallel edges can effect the chromatic
index. We will save this case for a future post.

Also in common with earlier posts, here we will use *Drake* as the basis for our
simulation. The hope being that others can reproduce our results by downloading
our `Drakefile` and running it.

We continue to use *geng* from *nauty* to generate the graph data we are
studying. For example, to colour all non-isomorphic, connected, simple graphs on
three vertices and count the colour used:

``` bash
$ geng -qc 3 | edge_colouring.py
2
3
```

So, of the two graphs in question, one ($P_{3}$) has been coloured with two
colours and the other ($K_{3}$) has been coloured with three colours.

As with vertex-colouring, the minimum number of colours in a proper
edge-colouring of a graph `\(G\)` is `\(\Delta(G)\)`. In contrast, though, by
Vizing’s theorem, at most one extra colour is required.

**Theorem (Vizing)**

> `\(\chi^{\prime}(G) \leq 1 + \Delta(G)\)`

A graph `\(G\)` for which `\(\chi^{\prime}(G) = \Delta(G)\)` is called *Class One*.
If `\(\chi^{\prime}(G) + 1\)` then `\(G\)` is called *Class Two*. By Vizing’s
theorem every graph is Class One or Class Two. `\(P_{3}\)` is an example of a
graph that is Class One and `\(K_{3}\)` is an example of a Class Two graph.

Vizing’s theorem says nothing, however, about how many colours our greedy
colouring program will use. We might, though, consider it moderately successful
were it to use not many more than `\(\Delta(G)\)` colours on average.

So we are going to consider the total number of colours used to colour all
graphs of order `\(n\)` as a proportion of the total maximum degree over the same
set of graphs.

To compute total number of colours used we follow this tip on summing values in
the console using *paste* and *bc*:

``` bash
$ geng -qc 3
 | edge_colouring.py
 | paste -s -d+
 | bc
5
```

To compute maximum degrees we depend upon the *maxdeg* program for *gvpr*. This
means that we have to pipe the output of *geng* through *listg* to convert it
into *DOT* format:

``` bash
$ geng -qc 3
 | listg -y
 | gvpr -fmaxdeg
max degree = 2, node 2, min degree = 1, node 0
max degree = 2, node 0, min degree = 2, node 0
```

The output from *maxdeg* contains much more information than we need and so we
need to pipe the output through *sed* to strip out the maximum degrees:

``` bash
$ geng -qc 3
 | listg -y
 | gvpr -fmaxdeg
 | sed -n 's/max degree = \([0-9]*\).*/\1/p'
2
2
```

Now, piping through *paste* and *bc* as before, we find the total over all
graphs of the maximum degrees:

``` bash
$ geng -qc 3
 | listg -y
 | gvpr -fmaxdeg
 | sed -n 's/max degree = \([0-9]*\).*/\1/p'
 | paste -s -d+
 | bc
4
```

Perhaps surprisingly, with this approach, we find a relatively small discrepancy
between the total number of colours used and the total maximum degree. For
example, for `\(n = 5\)` (below) the discrepancy is 18 or 25%.

``` bash
$ time geng -qc 5
 | edge_colouring.py
 | paste -s -d+
 | bc
90

real    0m0.416s
user    0m0.328s
sys 0m0.068s
```

``` bash
$ time geng -qc 5
 | listg -y
 | gvpr -fmaxdeg
 | sed -n 's/max degree = \([0-9]*\).*/\1/p'
 | paste -s -d+
 | bc
72

real    0m0.014s
user    0m0.004s
sys 0m0.004s
```

For `\(n = 10\)` the discrepancy is 9189586, or less than 12% of the total of
maximum degrees.

``` bash
$ time geng -qc 10
 | edge_colouring.py
 | paste -s -d+
 | bc
87423743

real    135m6.838s
user    131m38.614s
sys 0m12.305s
```

``` bash
$ time geng -qc 10
 | listg -y
 | gvpr -fmaxdeg
 | sed -n 's/max degree = \([0-9]*\).*/\1/p'
 | paste -s -d+
 | bc
78234157

real    48m52.294s
user    51m43.042s
sys 0m12.737s
```

## Results

We repeated the experiment described in the previous section for all values of
`\(n\)` from 2 to 10. The results are presented in the plot below which is based
on
[Matplotlib basic plotting from a text file.](http://stackoverflow.com/questions/11248812/matplotlib-basic-plotting-from-text-file)

![A bar plot with graph order on the x-axis (going from 2 to 10) and number of colours divided by maximum degree on the y-axis (going from 0 to 2). The bar at 2 on the x-axis has height one and therefore the total number of colours used by a greedy strategy for all graphs of order 2 is equal to the total maximum degree over all those graphs. All of the bars are between 1 and 1.5. Apart from bars 2 and 4, all others are greater than 1, indicating that more colours are needed on graphs of those order than the sum of maximum degrees of all graphs of that order. The heighest bars are for orders 3 and 5.](plot.svg)

For all orders the total number of colours used by our greedy method is between
1 and 1.5 times the total maximum degree. There also seems to be a tendancy
towards a smaller proportion for larger values of `\(n\)`. Two theoretical results
are relevant here.

The first is Shannon’s theorem which concerns the chromatic index of
multigraphs:

**Theorem (Shannon)**

> `\(\chi^{\prime}(G) \leq \frac{3\Delta(G)}{2}\)`

Shannon’s theorem applies for our experiment because every simple graph is a
multigraph with maximum multiplicity 1. An interesting experiment is to see if
the results of the above experiment extend to multigraphs. Shannon’s theorem
guarantees that for some colouring method it is possible but says nothing about
the performance of our specific method.

A result which is relevant to the second observation, that the proportion tends
to 1, concerns the distribution of simple graphs among Class One and Class Two.

**Theorem (10.5 from Chartrand and Zhang (2008))**

> Almost every graph is Class One, that is
> `\(\lim_{n \rightarrow \infty}\frac{|G_{n,1}|}{|G_{n}|} = 1\)`

where `\(G_{n}\)` denotes the set of graphs of order `\(n\)` and `\(G_{n, 1}\)` is the
set of Class One graphs of order `\(n\)`.

So we have good reason to hope that, on average, with larger sets of simple
graphs we use fewer colours on average.

In the source code section below there is a *Drakefile* which should reproduce
this plot from scratch (provided that the required software is installed).

## Source Code

{{% gist "MHenderson" "09731e22e87bd6ca708d" %}}

{{% gist "MHenderson" "2887c84f541f6c782323" %}}

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-chartrandChromaticGraphTheory2008" class="csl-entry">

Chartrand, Gary, and Ping Zhang. 2008. *Chromatic Graph Theory*. CRC Press.

</div>

</div>
