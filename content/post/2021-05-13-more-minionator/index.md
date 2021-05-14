---
title: (WIP) More Minionator
author: Matthew Henderson
date: '2021-05-13'
slug: minionator
categories:
  - constraints
tags:
  - r-packages
  - r
  - minion-r
draft: yes
---

So why use Minionator?

Suppose now you want to find larger latin squares. If you create a Minion input file by hand then you will have to write a lot more code than the Minionator version. A better approach would be to write a function that generates the output. We can easily write functions to generate the row and column constraints from a parameter equal to the order of the latin square. We don’t even need Minionator to do this but if we are using Minionator then we would end up with something like this.

Code for a parameterised version of the latin square generator.

The benefits of using Minionator don’t stop at just allowing us to create large input files more easily. Perhaps the greatest benefit is that the use of data frames to represent the variables and constraints makes it easier to compose constraints and also to construct constraints over complex variable ranges.

As an example, consider the problem of constructing a pair of mutually orthogonal latin squares of order n. If we are working directly with Minion input files then we would have a lot of cutting-and-pasting to do. With Minionator we can just create two discrete matrices and a function that given a matrix returns the latin constraints for that matrix. Now only the orthogonality question remains.

Code for two latin squares using previously demonstrated latin constraints function.

One approach is to use a constraint on vectors. We can insist that in our solution the pair (i,j) is different to the pair (k,l) whenever i<>j or k<>l. To reduce the number of constraints (not necessarily advantageous) we can also insist that i < k. Tools from the tidyverse make it easy to construct this set of indices. The purrr package then makes it easy to construct from a dataframe of these variables a new dataframe which represents the vector inequality constraint over every pair of pairs.

Code for MOLS.

Calling Minion with this input file we can easily find a pair of mutually orthogonal latin squares of order X. Or even enumerate MOLS of small order.

Calling Minion via R to generate MOLS.

We will look at some more examples now and hope to convince you that using Minionator makes life easier in certain cases. I think having your variables and constraints in data frames makes life a lot easier than if you try to write code to do the same thing with strings and loops etc … The main argument is that the tidyverse and related tools makes it easy to build up the data frame of variables and then to subset it in various complicated ways. Of course you could do it all in your own code working with the output strings directly, but you would probably have to rewrite a lot of code similar to what is already available in the tidyverse (or even just base R). A good example is cross_df.
