---
title: Room Squares
summary: Investigations into Room squares
tags:
- combinatorics
date: "2020-11-18T00:00:00Z"
---

A Room square, named after Thomas Gerald Room, is an n × n array filled with n + 1 different symbols in such a way that:

    Each cell of the array is either empty or contains an unordered pair from the set of symbols
    Each symbol occurs exactly once in each row and column of the array
    Every unordered pair of symbols occurs in exactly one cell of the array.

An example, a Room square of order seven, if the set of symbols is integers from 0 to 7: 

<table class="wikitable" style="margin-left:auto;margin-right:auto;text-align:center;width:18em;height:18em;table-layout:fixed;">

<tbody><tr>
<td>0,7</td>
<td></td>
<td></td>
<td>1,5</td>
<td></td>
<td>4,6</td>
<td>2,3
</td></tr>
<tr>
<td>3,4</td>
<td>1,7</td>
<td></td>
<td></td>
<td>2,6</td>
<td></td>
<td>0,5
</td></tr>
<tr>
<td>1,6</td>
<td>4,5</td>
<td>2,7</td>
<td></td>
<td></td>
<td>0,3</td>
<td>
</td></tr>
<tr>
<td></td>
<td>0,2</td>
<td>5,6</td>
<td>3,7</td>
<td></td>
<td></td>
<td>1,4
</td></tr>
<tr>
<td>2,5</td>
<td></td>
<td>1,3</td>
<td>0,6</td>
<td>4,7</td>
<td></td>
<td>
</td></tr>
<tr>
<td></td>
<td>3,6</td>
<td></td>
<td>2,4</td>
<td>0,1</td>
<td>5,7</td>
<td>
</td></tr>
<tr>
<td></td>
<td></td>
<td>0,4</td>
<td></td>
<td>3,5</td>
<td>1,2</td>
<td>6,7
</td></tr></tbody></table>

In this project we are investigating several unsolved problems
involving Room squares.

(Okay, so we definitely want to mirror things for sharing. Gitlab
is for private development. Use Github or Sourcehut).

Some of the work we have done so far is summarised in the report:
* https://gitlab.com/mjhlab/room

There is also a website version of this report:
* https://gitlab.com/mjhlab/room-bookdown

We have implemented Dinitz and Stinson's hill-climbing algorithm
for constructing Room squares in Java.
* https://gitlab.com/MHenderson1/room-square-generator

A bibliography of Room squares is available here:
* https://gitlab.com/mjhlab/room-squares-bib
