---
title: Chromatic Polynomials
author: Matthew Henderson
date: '2014-07-11'
slug: chromatic-polynomials
categories:
  - graph-theory
tags:
  - python
  - networkx
  - sympy
subtitle: ''
excerpt: 'Computing chromatic polynomials in Python.'
draft: no
series: ~
layout: single
references:
- id: bjorklundComputingTuttePolynomial2008
  abstract: >-
    The deletion-contraction algorithm is perhaps the most popular method for
    computing a host of fundamental graph invariants such as the chromatic,
    flow, and reliability polynomials in graph theory, the Jones polynomial of
    an alternating link in knot theory, and the partition functions of the
    models of Ising, Potts, and Fortuin-Kasteleyn in statistical physics. Prior
    to this work, deletion-contraction was also the fastest known
    general-purpose algorithm for these invariants, running in time roughly
    proportional to the number of spanning trees in the input graph.Here, we
    give a substantially faster algorithm that computes the Tutte polynomial-and
    hence, all the aforementioned invariants and more-of an arbitrary graph in
    time within a polynomial factor of the number of connected vertex sets. The
    algorithm actually evaluates a multivariate generalization of the Tutte
    polynomial by making use of an identity due to Fortuin and Kasteleyn. We
    also provide a polynomial-space variant of the algorithm and give an
    analogous result for Chung and Graham's cover polynomial.
  author:
    - family: Björklund
      given: Andreas
    - family: Husfeldt
      given: Thore
    - family: Kaski
      given: Petteri
    - family: Koivisto
      given: Mikko
  container-title: 2008 49th Annual IEEE Symposium on Foundations of Computer Science
  DOI: 10.1109/FOCS.2008.40
  event: 2008 49th Annual IEEE Symposium on Foundations of Computer Science
  ISSN: 0272-5428
  issued:
    - year: 2008
      month: 10
  page: 677-686
  source: IEEE Xplore
  title: Computing the Tutte Polynomial in Vertex-Exponential Time
  type: paper-conference
---

Until now we have considered two different simple methods for colouring
vertices of graphs. Greedy colouring and recursive removal of independent
subgraphs. Neither of which guarantee a colouring with the minimum number of
colours under the most general conditions.

In the last few posts we did some simple experimentation to compare the total
of chromatic numbers over all graphs on at most seven vertices against the
total colours used by our greedy and recursive independent set extraction
methods. This experimentation turned up some unexpected numbers and so it
became necessary to investigate the data we have been using more closely so
as to rule out corrupt data as a reason for the discrepancy.

We observed two things from these small experiments. Firstly, we observed that
both methods used more colours than the minimum. We also observed that our
NetworkX-based implementation of the greedy method appears to use many more
colours than Joseph Culberson’s C version. For this reason we started to think
about ways in which we could verify the data used.

As we know the distribution of chromatic numbers over small graphs, one method
to verify the graph data we are using is to try to reproduce this chromatic
distribution data.

In this post we therefore present an implementation of the chromatic number
based on the chromatic polynomial. In upcoming posts we will return to the
verification of experimental data collected in previous posts.

## The Chromatic Polynomial

The **chromatic polynomial** `\(\chi_{G}(\lambda)\)` is the number of
`\(\lambda\)`-colourings of `\(G\)`. The chromatic polynomial is, as the name
suggests, a polynomial function. To compute values of the chromatic polynomial,
which can then be used to calculate the chromatic number, we will exploit the
fact that it is a special case of the [**Tutte polynomial**](http://en.wikipedia.org/wiki/Tutte_polynomial)
`\(T_{G}(x, y)\)`.

**Theorem**

`$$\chi_{G}(\lambda) = (-1)^{\|V\| - \kappa(G)}\lambda^{\kappa(G)}T_{G}(1 - \lambda, 0)$$`

The Tutte polynomial has been implemented by
Björklund et al. (2008)
in the
[*tutte_bhkk* module](https://github.com/thorehusfeldt/tutte_bhkk)
for NetworkX.
Having an implementation of the Tutte polynomial, by the above Theorem, makes
our job of implementing the chromatic polynomial a near triviality.

In the *tutte_bhkk* module there is a function `tutte_poly` which returns a
nested list of coefficients of the Tutte polynomial. Our implementation of the
chromatic polynomial will create a polynomial object rather than a coefficient
list. So first we create a function that translates the *tutte_bhkk*
coefficient list into a \[*sympy*\]\[sympy\] polynomial. This is done by building a
string representation of the Tutte polynomial of a graph and then using the
ability of `sympy.poly` to construct a polynomial object from such a parameter
string.

``` python
import sympy
from tutte import tutte_poly
import networkx as nx

def tutte_polynomial(G):
    T = tutte_poly(G)
    s = ' + '.join(['{0}*x**{1}*y**{2}'.format(T[i][j], i, j) for i in range(len(T)) for j in range(len(T[i]))])
    return sympy.poly(s)
```

With this function now we can find, for example, the Tutte polynomial of the
Petersen graph.

``` python
P = nx.petersen_graph()
tutte_polynomial(P)
```

`\(\operatorname{Poly}{\left( x^{9} + 6 x^{8} + 21 x^{7} + 56 x^{6} + 12 x^{5} y + 114 x^{5} + 70 x^{4} y + 170 x^{4} + 30 x^{3} y^{2} + 170 x^{3} y + 180 x^{3} + 15 x^{2} y^{3} + 105 x^{2} y^{2} + 240 x^{2} y + 120 x^{2} + 10 x y^{4} + 65 x y^{3} + 171 x y^{2} + 168 x y + 36 x + y^{6} + 9 y^{5} + 35 y^{4} + 75 y^{3} + 84 y^{2} + 36 y, x, y, domain=\mathbb{Z} \right)}\)`

With the Tutte polynomial implemented as a *sympy* polynomial constructing the
chromatic polynomial of a graph is a no more than a simple expression. For
greater convenience we embody this expression in a function,
`chromatic_polynomial`.

``` python
from sympy.abc import x,y,l

def chromatic_polynomial(G):
    k = nx.number_connected_components(G)
    tp = tutte_polynomial(G).subs({x: 1 - l, y: 0})
    return sympy.expand((-1)**(G.number_of_nodes() - k)*l**k*tp)
```

Returning to the Petersen graph, the chromatic polynomial is:

``` python
cp = chromatic_polynomial(P)
cp
```

`\(- l \operatorname{Poly}{\left( - l^{9} + 15 l^{8} - 105 l^{7} + 455 l^{6} - 1353 l^{5} + 2861 l^{4} - 4275 l^{3} + 4305 l^{2} - 2606 l + 704, l, domain=\mathbb{Z} \right)}\)`

Now to use the chromatic polynomial to find the chromatic number of a graph it
should be clear what we have to do. The `Poly` member function `subs`
allows us to compute values of the chromatic polynomial. As there are no
2-colourings of the Petersen graph we expect that `cp.subs(l, 2)` is zero,
which it is.

``` python
cp.subs(l, 2)
0
```

Then if we compute `cp.subs(l, 3)` we are not surprised to see a non-zero value
because we already knew that the chromatic number of the Petersen graph is 3.

``` python
cp.subs(l, 3)
120
```

We see that the chromatic number of the Petersen graph is 3 because that is
the least integral value of `\(\lambda\)` for which `\(\chi(G, \lambda) > 0\)`,
when `\(G\)` is the Petersen graph.

The same calculations for the Chvatal graph show that the chromatic number of
the Chvatal graph is 4:

``` python
C = nx.chvatal_graph()
cp2 = chromatic_polynomial(C)

cp2.subs(l, 3)
0
cp2.subs(l, 4)
18024
```

Apart from some simple cases with graphs with no edge or vertices the chromatic
number is found by as the least `\(\lambda \in \{1, \ldots, \Delta(G) + 1\}\)`
for which `\(\chi(G, \lambda) > 0\)`.

``` python
def chromatic_number(G):
    if G.number_of_nodes() == 0:
        return 0
    elif G.number_of_edges() == 0:
        return 1
    elif G.number_of_edges() == 1:
        return 2
    else:
        p = chromatic_polynomial(G)
        for i in range(max(G.degree().values()) + 2):
            if p.subs(l, i) > 0:
                return i
```

## Chromatic Numbers of Small Graphs

In this section we return again to the set of all graphs on at most seven
vertices, albeit with more care than was given in previous posts. The first
objective is to reproduce Gordon Royle’s table of chromatic numbers of small
graphs as far as graphs on seven vertices. In doing this we recognise one
reason for previously reported discrepant data. Royle’s table is a table of
chromatic numbers for connected graphs whereas our approximations to the sum
of all chromatic numbers were computed over the set of all graphs of order at
most seven.

Below, we construct two lists `data` and `c_data`. The `data` list is populated
with the chromatic number data for all graphs in the set `graph_atlas_g()` of
all graphs on at most seven vertices. The `c_data` list records the same data
but only for connected graphs.

``` python
from networkx.generators.atlas import graph_atlas_g
G = graph_atlas_g()

data = [8*[0] for i in range(8)]
c_data = [8*[0] for i in range(8)]

for g in G:
    n = g.number_of_nodes()
    c = chromatic_number(g)
    data[c][n] += 1
    if nx.number_connected_components(g) == 1:
        c_data[c][n] += 1
```

Creating a table of the distribution of chromatic numbers over all connected
graphs of order at most seven we reproduce Royle’s data. The function
`html_table` (not shown here) is based on Caleb Madrigal’s post
[*Display List as Table in IPython Notebook*](http://calebmadrigal.com/display-list-as-table-in-ipython-notebook/).

``` python
from IPython.display import HTML

T = [['$\chi$','$n = 3$','$n = 4$','$n = 5$','$n = 6$','$n = 7$']]

rows = c_data[2:]

for i in range(len(rows)):
    R = [i + 2]
    for cell in rows[i][3:]:
      R.append(cell)
    T.append(R)

HTML(html_table(T))
```

<table>
<tr>
<td>
$\chi$
</td>
<td>
$n = 3$
</td>
<td>
$n = 4$
</td>
<td>
$n = 5$
</td>
<td>
$n = 6$
</td>
<td>
$n = 7$
</td>
</tr>
<tr>
<td>
2
</td>
<td>
1
</td>
<td>
3
</td>
<td>
5
</td>
<td>
17
</td>
<td>
44
</td>
</tr>
<tr>
<td>
3
</td>
<td>
1
</td>
<td>
2
</td>
<td>
12
</td>
<td>
64
</td>
<td>
475
</td>
</tr>
<tr>
<td>
4
</td>
<td>
0
</td>
<td>
1
</td>
<td>
3
</td>
<td>
26
</td>
<td>
282
</td>
</tr>
<tr>
<td>
5
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
<td>
4
</td>
<td>
46
</td>
</tr>
<tr>
<td>
6
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
<td>
5
</td>
</tr>
<tr>
<td>
7
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
</tr>
</table>

The same data over all graphs of order at most seven is given in the following
table.

``` python
rows = data[2:]

T = [['$\chi$','$n = 3$','$n = 4$','$n = 5$','$n = 6$','$n = 7$']]

for i in range(len(rows)):
    R = [i + 2]
    for cell in rows[i][3:]:
      R.append(cell)
    T.append(R)

HTML(html_table(T))
```

<table>
<tr>
<td>
$\chi$
</td>
<td>
$n = 3$
</td>
<td>
$n = 4$
</td>
<td>
$n = 5$
</td>
<td>
$n = 6$
</td>
<td>
$n = 7$
</td>
</tr>
<tr>
<td>
2
</td>
<td>
2
</td>
<td>
6
</td>
<td>
12
</td>
<td>
34
</td>
<td>
87
</td>
</tr>
<tr>
<td>
3
</td>
<td>
1
</td>
<td>
3
</td>
<td>
16
</td>
<td>
84
</td>
<td>
579
</td>
</tr>
<tr>
<td>
4
</td>
<td>
0
</td>
<td>
1
</td>
<td>
4
</td>
<td>
31
</td>
<td>
318
</td>
</tr>
<tr>
<td>
5
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
<td>
5
</td>
<td>
52
</td>
</tr>
<tr>
<td>
6
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
<td>
6
</td>
</tr>
<tr>
<td>
7
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
0
</td>
<td>
1
</td>
</tr>
</table>

So this gives us some confidence in the NetworkX data as well as the above
method for computing chromatic numbers.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bjorklundComputingTuttePolynomial2008" class="csl-entry">

Björklund, Andreas, Thore Husfeldt, Petteri Kaski, and Mikko Koivisto. 2008. “Computing the Tutte Polynomial in Vertex-Exponential Time.” In *2008 49th Annual IEEE Symposium on Foundations of Computer Science*, 677–86. <https://doi.org/10.1109/FOCS.2008.40>.

</div>

</div>
