---
title: "(WIP) Tidy Tuesday: Internet Access"
author: Matthew Henderson
description: My Tidy Tuesday contribution for 2021, week 20.
date: '2021-05-11'
slug: internet-access
categories:
  - dataviz
tags:
  - tidy-tuesday
draft: yes
editor_options: 
  chunk_output_type: console
---



This week's Tidy Tuesday data comes from two sources,
[Microsoft](https://github.com/microsoft/USBroadbandUsagePercentages)
and
[the FCC](https://www.fcc.gov/document/broadband-deployment-report-digital-divide-narrowing-substantially-0)
by way of
[The Verge](https://www.theverge.com/22418074/broadband-gap-america-map-county-microsoft-data).

This was the first time I can remember using the
[{tigris}](https://cran.r-project.org/web/packages/tigris/index.html)
package.
What a joy it was to use!
Made it so easy to get data
about US counties.

Having lived there
for a few years,
I quickly narrowed in on Kentucky
and briefly got sidetracked
plotting towns and landmarks.

The data was already very
clean
which made plotting easy.
In the case of Kentucky
there was no missing data either.

I spent most time trying to
position the annotations
and add footnotes.
I also spent quite a lot
of time fiddling around
with different font choices
but couoldn't find anything
I liked better than Cardo.

Instead of posting a link
to this blog on Twitter
and LinkedIn
I simply uploaded the image
and wrote a short post
using the Twitter app for Android,
hoping that it wouldn't
crop the image like the desktop app
seems to.
Alas, it seemed to crop anyway.

Source code: https://github.com/MHenderson/internet-access

![](https://raw.githubusercontent.com/MHenderson/internet-access/master/internet-access.png)