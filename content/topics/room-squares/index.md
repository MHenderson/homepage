---
title: Room Squares
author: Matthew Henderson
date: "2021-05-11"
slug: room-squares
categories:
  - combinatorics
tags:
  - room-squares
---

A **Room square**
is an `\(n × n\)` array filled with `\(n + 1\)`
different symbols in such a way that:

  1. Each cell of the array is either empty or contains an unordered pair
     from the set of symbols
  2. Each symbol occurs exactly once in each row and column of the array
  3. Every unordered pair of symbols occurs in exactly one cell of the array.

<table>
<caption>Table 1: A Room square of order 7.</caption>
<tbody>
  <tr>
   <td style="text-align:left;"> 0,7 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1,5 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 4,6 </td>
   <td style="text-align:left;"> 2,3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3,4 </td>
   <td style="text-align:left;"> 1,7 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 2,6 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 0,5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1,6 </td>
   <td style="text-align:left;"> 4,5 </td>
   <td style="text-align:left;"> 2,7 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 0,3 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 0,2 </td>
   <td style="text-align:left;"> 5,6 </td>
   <td style="text-align:left;"> 3,7 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1,4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2,5 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1,3 </td>
   <td style="text-align:left;"> 0,6 </td>
   <td style="text-align:left;"> 4,7 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3,6 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 2,4 </td>
   <td style="text-align:left;"> 0,1 </td>
   <td style="text-align:left;"> 5,7 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 0,4 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3,5 </td>
   <td style="text-align:left;"> 1,2 </td>
   <td style="text-align:left;"> 6,7 </td>
  </tr>
</tbody>
</table>

I'm writing a
[monograph](/projects/room)
about Room squares.

A long time ago
I wrote some code in Visual Basic
to generate Room squares
using Dinitz and Stinson's
hill-climbing approach.
Lately,
I've been working
on a
[Java version](/projects/room-square-generator).
