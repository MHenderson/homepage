---
title: Asaverse
author: Matthew Henderson
categories:
  - projects
date: "2021-03-10"
slug: asaverse
tags:
  - docker
  - rstudio
  - rocker
draft: true
---

A Docker container based on rocker/verse

* [source](https://gitlab.com/mjhds/asaverse) - on Gitlab

## Why create my own Docker container?

The rocker project already has containers that are nearly
perfect for my use case. Asaverse just adds renv and configures
the container to use an renv cache on the host machine. This
means that even if a project needs to install packages again
after the local library has been removed then it will be
lightning fast (assuming that the cache on the host is relatively
up-to-date).

I also have added a large number of fonts and packages for LaTeX
to make it possible to compile things like my CV without
having to install anything extra at compile time.
