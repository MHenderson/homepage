---
title: (WIP) Accessibility for Blogdown
author: Matthew Henderson
date: '2021-05-14'
slug: accessibility
categories:
  - blogging
tags:
  - blogdown
  - accessibility
draft: yes
---

I'm trying to make my blog more accessible.

The main tool I've using is:
https://accessibilitytest.org

But I also found that the Firefox accessibility tools
are useful. For example, to find elements with low
contrast between foreground and background. In my
case there was a problem with commented code in
highlighted regions. I couldn't find a colour theme
that didn't have this problem so I removed comments.

[Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
at MDN Web Docs.

[Make your website or app accessible and publish an accessibility statement](https://www.gov.uk/guidance/make-your-website-or-app-accessible-and-publish-an-accessibility-statement)
at gov.uk

I got ideas for colours
from the Carnegie Museums of Pittsburgh:
[Web Accessibility Guidelines v1.0](http://web-accessibility.carnegiemuseums.org/design/color/) 

A few specific things I had to figure out:

## labelling icons

https://stackoverflow.com/questions/41285466/how-do-i-add-add-text-below-font-awesome-icon-links#41285702
https://developer.mozilla.org/en-US/docs/Web/Accessibility/Understanding_WCAG/Text_labels_and_names#interactive_elements_must_be_labeled

## source code highlighting

commented code is not accessible because there's not enough contrast against
the background

same goes for adding line numbers (depending on style)

https://www.r-bloggers.com/2020/05/syntax-highlighting-in-blogdown-a-very-specific-solution/
https://xyproto.github.io/splash/docs/all.html
