---
title: Functional Geometry in R
author: Matthew Henderson
date: '2018-01-16'
slug: functional-geometry-in-r
categories:
  - generative-art
tags:
  - r
  - r-package
bibliography: [funcgeo.bib]
---

This post introduces
**funcgeo**,
an R package
for functional geometry,
by recreating Square Limit
by M. Escher
(Fig. 1)
following the approach of
Henderson (1982).

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/squarelimit-1.png" alt="Square Limit" width="480" />

<p class="caption">

Figure 1: Square Limit

</p>

</div>

Peter Henderson describes
Functional Geometry in two papers:
Henderson (1982)
and
Henderson (2002).
In those papers
he shows
how to define
a language of pictures
using basic concepts
of functional programming.

[**funcgeo**](https://mhenderson.github.io/funcgeo/)
implements a picture language
like the one described in
Henderson (1982).

To install
**funcgeo**
use `install_gitlab` from
the **remotes** package.

``` r
#install.packages("remotes")
remotes::install_gitlab("MHenderson1/funcgeo")
```

The next section
introduces the basic fish pictures
used to construct Square Limit.

After that,
in subsequent sections,
the fish
are combined into
more complex pictures
where the lines of the fish
are connected
at picture boundaries.
The penultimate step
before constructing
the complete Square Limit picture
is to combine the complex pictures
into the sides
and corners
of Square Limit.

# Fish

The fish from
Henderson (1982)
are available in **funcgeo**
as package data:
`fish_p`,
`fish_q`,
`fish_r`
and
`fish_s`.
All fish
have class `picture`
and **funcgeo** implements
a `plot` method for
`picture`s.

``` r
library(funcgeo)

plot(fish_p)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/p-1.png" alt="Fish P" width="192" />

<p class="caption">

Figure 2: Fish P

</p>

</div>

``` r
plot(fish_q)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/q-1.png" alt="Fish Q" width="192" />

<p class="caption">

Figure 3: Fish Q

</p>

</div>

# Combining fish

Picture operations from
Henderson (1982)
like `rot`, `flip`
and `cycle`
are implemented in **funcgeo**.

For example,
the `quartet` operation
described in Henderson (1982)
is used to combine
the four fish
into `t`,
one of the building blocks
of Square Limit.

``` r
t <- quartet(fish_p, fish_q, fish_r, fish_s)

plot(t)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/t-1.png" alt="t" width="288" />

<p class="caption">

Figure 4: t

</p>

</div>

Similarly,
`cycle`
and `rot`
functions
are used to create
`u` from `fish_q`.

``` r
u <- cycle(rot(fish_q))

plot(u)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/u-1.png" alt="u" width="288" />

<p class="caption">

Figure 5: u

</p>

</div>

# Sides

`quartet`
is also required
for building `side1`,
one of the more complex
pieces of Square Limit.
`side1` also requires
the `rot` operation
and `nil` empty picture.

``` r
side1 <- quartet(nil, nil, rot(t), t)

plot(side1)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/side1-1.png" alt="Side 1" width="288" />

<p class="caption">

Figure 6: Side 1

</p>

</div>

`side2` is created
as a `quartet`
involving several pictures,
including `side1`.

``` r
side2 <- quartet(side1, side1, rot(t), t)

plot(side2)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/side2-1.png" alt="Side 2" width="288" />

<p class="caption">

Figure 7: Side 2

</p>

</div>

# Corners

The goal
of this section
is to reproduce
`corner` from
Henderson (1982).
Square Limit is created
by calling the `cycle` operation
on `corner`.
However,
creating `corner`
requires first creating
`corner2`,
which itself is based
on `corner1`
which is a `quartet`
of three null pictures
and `u`.

``` r
corner1 <- quartet(nil, nil, nil, u)

plot(corner1)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/corner1-1.png" alt="Corner 1" width="288" />

<p class="caption">

Figure 8: Corner 1

</p>

</div>

`corner2` is also
a `quartet`
made from `corner1`
`side1`
and `u`.

``` r
corner2 <- quartet(corner1, side1, rot(side1), u)

plot(corner2)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/corner2-1.png" alt="Corner 2" width="288" />

<p class="caption">

Figure 9: Corner 2

</p>

</div>

`nonet` is a
`\(3 \times 3\)`
equivalent of `quartet`
and is used
with `corner2`
`side2`,
`u`,
`t`,
and `fish_q`
to create `corner`,
the only picture
we need to create
Square Limit.

``` r
corner <- nonet(
  corner2, side2, side2,
  rot(side2), u, rot(t),
  rot(side2), rot(t), rot(fish_q)
)

plot(corner)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/corner-1.png" alt="Corner" width="288" />

<p class="caption">

Figure 10: Corner

</p>

</div>

# Square Limit

Square Limit now is
just `cycle`
with `corner`.

``` r
squarelimit <- cycle(corner)

plot(squarelimit)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/squarelimit2-1.png" alt="Square Limit" width="480" />

<p class="caption">

Figure 11: Square Limit

</p>

</div>

# References

<div id="refs" class="references">

<div id="ref-Henderson:1982:FG">

Henderson, Peter. 1982. “Functional Geometry.” In *Proceedings of the 1982 Acm Symposium on Lisp and Functional Programming*, 179–87. LFP ’82. New York, NY, USA: ACM. <https://doi.org/10.1145/800068.802148>.

</div>

<div id="ref-Henderson:2002:FG">

———. 2002. “Functional Geometry.” *Higher-Order and Symbolic Computation* 15 (4): 349–65. <https://doi.org/10.1023/A:1022986521797>.

</div>

</div>
