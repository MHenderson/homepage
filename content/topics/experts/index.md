---
title: Predictions from Expert Advice
author: Matthew Henderson
date: "2021-06-17"
slug: experts
categories:
  - machine-learning
tags:
  - python
  - expert-learning
draft: yes
references:
- id: hendersonMixtureVectorExperts2005
  abstract: >-
    We describe and analyze an algorithm for predicting a sequence of
    n-dimensional binary vectors based on a set of experts making vector
    predictions in [0,1] n . We measure the loss of individual predictions by
    the 2-norm between the actual outcome vector and the prediction. The loss of
    an expert is then the sum of the losses experienced on individual trials. We
    obtain bounds for the loss of our expert algorithm in terms of the loss of
    the best expert analogous to the well-known results for scalar experts
    making real-valued predictions of a binary outcome.
  accessed:
    - year: 2018
      month: 7
      day: 4
  author:
    - family: Henderson
      given: Matthew
    - family: Shawe-Taylor
      given: John
    - family: Žerovnik
      given: Janez
  collection-title: Lecture Notes in Computer Science
  container-title: Algorithmic Learning Theory
  DOI: 10.1007/11564089_30
  event: International Conference on Algorithmic Learning Theory
  ISBN: 978-3-540-29242-5 978-3-540-31696-1
  issued:
    - year: 2005
      month: 10
      day: 8
  language: en
  page: 386-398
  publisher: Springer, Berlin, Heidelberg
  source: link.springer.com
  title: Mixture of Vector Experts
  type: paper-conference
  URL: https://link.springer.com/chapter/10.1007/11564089_30
---

You can imagine many different situations where predictions
of a sequence are made by a pool of experts. Outcomes of
sporting events, for example, are often forecast by pundits.
A wide range of commentators make predictions about
the future direction of stock markets.

Algorithms for combining predictions of experts are therefore
of interest. In particular, the idea of an online algorithm
that looks at forecasts and makes its own prediction for
the next element in the sequence. In this field of prediction
with expert advice there are several results that show an
online algorithm can do nearly as well as the best expert in
a pool without any idea about which expert is the best over
the whole sequence.

In this area I co-authored a paper
Henderson, Shawe-Taylor, and Žerovnik (2005)
that showed this kind of result is possible
when the outcome sequence is vector-valued,
useful for making predictions on a portfolio of
stocks, for example, in light of expert advice.

The algorithm described in
Henderson, Shawe-Taylor, and Žerovnik (2005)
is implemented in the
[experts](/projects/experts) Python library.

The simulations described in
Henderson, Shawe-Taylor, and Žerovnik (2005)
are available in the
[expert-learning](/projects/expert-learning)
Jupyter notebooks.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-hendersonMixtureVectorExperts2005" class="csl-entry">

Henderson, Matthew, John Shawe-Taylor, and Janez Žerovnik. 2005. “Mixture of Vector Experts.” In *Algorithmic Learning Theory*, 386–98. Lecture Notes in Computer Science. Springer, Berlin, Heidelberg. <https://doi.org/10.1007/11564089_30>.

</div>

</div>
