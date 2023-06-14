---
title: More on Testing Graph Properties
author: ''
date: '2014-10-10'
slug: more-on-testing-graph-properties
categories:
  - graph-theory
tags:
  - software-testing
subtitle: ''
excerpt: 'An approach to testing graph properties based on Bats.'
draft: yes
series: ~
layout: single
---

In
[Testing Graph Properties](/post/2014/04/04/more-graph-testing)
an approach to testing graph data using CUnit is described.
In this post we describe an alternative approach using
[Bats](https://github.com/sstephenson/bats).

Introduction
------------

In
[graphs-collection](http://mhenderson.github.io/graphs-collection/)
there are data files in a variety of formats that purport to represent certain graphs.
Most graph formats represent graphs as list of edges or arrays of adjacencies.
For even modest graphs of more than a few vertices and edges it quickly becomes difficult to verify whether certain data represents a graph in a specific format or not.
For other formats, like the compressed *graph6* format, human checking is practically impossible.

There are other virtues to automated tests for a collection of graph data.
One significant benefit is that a collection of graph data, once verified, becomes a resource for testing graph algorithms.

Graph Property Testing
----------------------

One approach to testing graph data is to have one special representation trusted to represent a specific graph and then to test other representations against this special one.
In this post we take a different approach and focus on simpler, property-based testing.

Every graph has many different properties.
The simplest, like order and size, might even feature as part of a data format. Others, like the chromatic number, are parameters that have to be computed from graph data by algorithms.
The essence of graph property testing is to store known properties and their values as metadata and then, for every representation of a graph, check that computed values of all parameters match expected ones.

As an example, consider the following properties of the Chvatal graph, here given in YAML format.

    ---
    name: "Chvatal Graph"
    chromatic-number: 4
    diameter: 2
    girth: 4
    max-degree: 4
    order: 12
    radius: 2
    size: 24
    ...

A Bats test for the graph order is defined using the special Bats `@test` syntax.
The body of the test itself is a sequence of shell commands.
If all commands in this sequence exit with status 0 then the test passes.

    @test "Chvatal graph -> graph6 -> order" {
      [ $chvatal_g6_computed_order -eq $chvatal_expected_order ]
    }

The above test has a single command, a comparison between two values.
If the computed order and the expected order match then this test passes.
The string
`"Chvatal graph -> graph6 -> order"`
is simply a name for the test so that it can be identified in the output of Bats:

    bats ./src/Classic/Chvatal/tests/*.bats
     ✓ Chvatal graph -> graph6 -> diameter
     ✓ Chvatal graph -> graph6 -> girth
     ✓ Chvatal graph -> graph6 -> order
     ✓ Chvatal graph -> graph6 -> size
     ✓ Chvatal graph -> DOT -> chi
     ✓ Chvatal graph -> DOT -> maxdeg
     ✓ Chvatal graph -> DOT -> order
     ✓ Chvatal graph -> DOT -> size

To complete the testing setup we have to implement methods to assign the values of the above variables 
`$chvatal_g6_computed_order`
and
`$chvatal_expected_order`.

The latter can be accomplished with a simple *AWK* program that extracts the value from the `properties.yml` metadata file:

    cat properties.yml | awk -F": " "/order/"'{ print $2  }'

This pipeline finds the value of the `order` from the relevant record in the `properties.yml` file.
As this is something that we do many time with different property files and different properties we write a function with file and property as parameters.

    get_property() {
      property=$2
      s="/$property:/"'{ print $2  }'
      echo `cat `\(1 | awk -F": " "\)`s"`
    }

Now, for example, the expected order can be obtained thus:

    expected_order=$(get_property $properties_file order)

To compute the order of a graph from its data representation depends upon the data format used.
An implementation for graphs in *DOT* format can be based on the `gc` program from Graphviz (piping the output through *AWK* to strip out the value of the order):

    gv_order() { gc -n $1 | awk '{ print $1 }'; }

Now to compute the order from *DOT* data:

    chvatal_gv_computed_order=$(gv_order $chvatal_gv_path)
