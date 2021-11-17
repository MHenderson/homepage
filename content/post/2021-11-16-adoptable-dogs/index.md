---
title: "Tidy Tuesday: Adoptable Dogs"
description: "Week 51 of 2019."
author: Matthew Henderson
date: '2021-11-16'
slug: adoptable-dogs
categories:
  - dataviz
tags:
  - tidy-tuesday
editor_options: 
  chunk_output_type: console
draft: no
featured: yes
image: /dog-moves.png
references:
- id: rinkerSyllableSmallCollection2017
  author:
    - family: Rinker
      given: Tyler W.
  event-place: Buffalo, New York
  genre: manual
  issued:
    - year: 2017
  publisher-place: Buffalo, New York
  title: 'syllable: A small collection of syllable counting functions'
  type: report
  URL: http://github.com/trinker/syllable
- id: rudisStatebinsCreateUnited2020
  author:
    - family: Rudis
      given: Bob
  genre: manual
  issued:
    - year: 2020
  title: 'statebins: Create united states uniform cartogram heatmaps'
  type: report
  URL: https://gitlab.com/hrbrmstr/statebins
- id: pedersenPatchworkComposerPlots2020
  author:
    - family: Pedersen
      given: Thomas Lin
  genre: manual
  issued:
    - year: 2020
  title: 'patchwork: The composer of plots'
  type: report
---

Tidy Tuesday
for week fifty-one
of 2019
was all about
dogs available for adoption
in the United States
through PetFinder.

The data was collected by
Amber Thomas
for her piece
[Finding Forever Homes](https://pudding.cool/2019/10/shelters/)
which appeared
in
The Pudding
in October 2019.

There were three data sets.
One data set about
dogs that were moved between
states for adoption.
Another
described where dogs
were orginally found.
The third gave
detailed information about
every dog.

I created two plots from this data.

The first plot shows how
imports
and exports vary by state.
I used
Bob Rudis’s
{statebins}
package
Rudis (2020)
for this plot
as well as
Thomas Lin Pedersen’s
{patchwork}
package
Pedersen (2020).

![](dog-moves.png)

You can see that
lots of dogs are exported
from southern states,
particularly Texas.
You can also see that
lot of dogs are imported
to northern states
like Washington
and New York.

The second plot shows
the one hundred
most popular
dog names
among all dogs available
for adoption.

![](most-popular-names.png)

The colour of a name
in this plot
indicates whether it
has one,
two
or three syllables.
I used
Tyler Rinker’s
{syllable}
package
Rinker (2017)
to do this.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-pedersenPatchworkComposerPlots2020" class="csl-entry">

Pedersen, Thomas Lin. 2020. “Patchwork: The Composer of Plots.” Manual.

</div>

<div id="ref-rinkerSyllableSmallCollection2017" class="csl-entry">

Rinker, Tyler W. 2017. “Syllable: A Small Collection of Syllable Counting Functions.” Manual. Buffalo, New York. <http://github.com/trinker/syllable>.

</div>

<div id="ref-rudisStatebinsCreateUnited2020" class="csl-entry">

Rudis, Bob. 2020. “Statebins: Create United States Uniform Cartogram Heatmaps.” Manual. <https://gitlab.com/hrbrmstr/statebins>.

</div>

</div>
