---
title: (WIP) Tabular Playground Series
author: Matthew Henderson
date: '2021-06-11'
slug: tabular-playground-series
categories:
  - ml
tags:
  - kaggle
  - python
  - scikit-learn
draft: true
---

May 2021 I built a random forest that scored 1.09619 (log-loss)
versus the winning entry of 1.08763.

If I had that score in the final leaderboard I would have
placed 697 out of 1097. But of course there is no way to know
for sure because the scores in the final shakedown can move
a lot.

I found myself getting drawn into a lot of fiddling around with
my choices for cross validation thinking that a better model
would magically emerge. I tried different pre-processing and
found that nothing made an improvement. I was disheartened
until I read the post by the winner:

https://www.kaggle.com/c/tabular-playground-series-may-2021/discussion/243054

Looking at the Colab notebook he links to

https://colab.research.google.com/gist/academicsuspect/0aac7bd6e506f5f70295bfc9a3dc2250/tabular-may-baseline.ipynb?authuser=1#scrollTo=LtC_S97E8ep_

I saw that he ended
up with a very similar random forest to my model with similar
choices for hyper-parameters and similar error. So it probably
wasn't possible to do much better without using stacking or
some other ensemble methods with different models.

What I would like is to write-up what I did as a combination of
a repo containing notebooks with a baseline model, the
hyper-parameter tuning I did and also training and inference kernels.
It would be nice if all of that could be run in the cloud,
perhaps on Binder or something. Then this blog post can be
a more superficial description of what I did and point to that
repository for more details.
