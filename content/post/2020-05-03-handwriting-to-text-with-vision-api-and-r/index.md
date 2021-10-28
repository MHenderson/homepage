---
title: "(WIP) Extracting Text from Images using Google Vision API and R"
author: Matthew Henderson
slug: handwriting-to-text
date: '2020-05-03'
categories:
  - ml
tags:
  - ocr
draft: yes
editor_options: 
  chunk_output_type: console
references:
- id: urbanekBase64encToolsBase642015
  author:
    - family: Urbanek
      given: Simon
  genre: manual
  issued:
    - year: 2015
  title: 'base64enc: Tools for base64 encoding'
  type: report
  URL: http://www.rforge.net/base64enc
- id: wickhamHttrToolsWorking2020
  author:
    - family: Wickham
      given: Hadley
  genre: manual
  issued:
    - year: 2020
  title: 'httr: Tools for working with URLs and HTTP'
  type: report
- id: robinsonGutenbergrDownloadProcess2020
  author:
    - family: Robinson
      given: David
  genre: manual
  issued:
    - year: 2020
  title: 'gutenbergr: Download and process public domain works from project gutenberg'
  type: report
- id: oomsJsonlitePackagePractical2014
  author:
    - family: Ooms
      given: Jeroen
  container-title: arXiv:1403.2805 [stat.CO]
  issued:
    - year: 2014
  title: >-
    The jsonlite package: A practical and consistent mapping between JSON data
    and r objects
  type: article-journal
  URL: https://arxiv.org/abs/1403.2805
- id: derlooStringdistPackageApproximate2014
  author:
    - family: Loo
      given: M.P.J.
      non-dropping-particle: der
      dropping-particle: van
  container-title: The R Journal
  issue: '1'
  issued:
    - year: 2014
  page: 111-122
  title: The stringdist package for approximate string matching
  type: article-journal
  URL: https://CRAN.R-project.org/package=stringdist
  volume: '6'
---

In this post we describe how to use Google Cloud Platform,
in particular the Vision API, to extract text from images
in R.

Of particular interest here is the case when the
text being extracted is handwritten.

These are really
notes to myself as someone who writes a lot of notes by
hand and sometimes like to move those notes onto the computer.

Is it feasible to use OCR software for such a task?
Tesseract, which works
very well for OCR of typed characters does not seem to
do very well with handwriting. Google Vision API,
on the other hand, is able to extract text from handwriting.
But does it do it well enough to be useful? That’s what
we are interested in here.

# Preparation

Before doing anything in R
you have to
create a project on
Google Cloud Platform (GCP)
and enable Vision API.

In the appendix there are brief
notes about how to do this
but if you are using GCP
for the first time
it is probably better
to follow a tutorial
like the one at
https://cloud.google.com/vision/docs/setup
instead.

After creating your GCP project
you should find yourself
the proud owner
of a shiny new access token.

To run any of the code below
we need to tell R
what the access token
is without accidentally
revealing it to the world.

One of the easiest ways to do this is to use
the usethis package to edit .Renviron, either
at project score or user scope.

``` r
usethis::edit_r_environ(scope = "user")
```

Put into that file something like this:

    GCLOUD_ACCESS_TOKEN=<your access token here>

Be careful not to commit this file
to a Git repository.
Anyone who has the token
can potentially make requests
of your app
and force you to incur costs.
If this were to happen
you could revoke access
for that key
using the Google Cloud Console
(put a link here).

After defining your access token in
.Renviron you need to restart R. Then you
can check that the environment variable now
is defined to be equal to the access token
with
`Sys.getenv`:

``` r
Sys.getenv("GCLOUD_ACCESS_TOKEN")
```

Now we are ready
to being extracting text from images
in R.

In the next section I show you how to
extract text from a single image file.

Later I’ll show
how you can extract text from multiple images.

# Extracting handwriting from a single image

In this section
and the following ones
I make use of some images
of my own handwriting.

So I can compare the results
of using Vision API
against a known text
I have written out
several pages
of
[James Oliver Curwood](https://en.wikipedia.org/wiki/James_Oliver_Curwood)’s
novel
*Baree, Son of Kazan*
by hand.
For comparison
I use the
[text version of the novel from Project Gutenberg](https://www.gutenberg.org/ebooks/4748)

## Creating document text detection requests

Using Vision API
for image annotation
involves posting images over http to
`https://vision.googleapis.com/v1/images:annotate`
with a JSON payload
containing images
encoded as text
using the Base64 encoding scheme.
(see https://en.wikipedia.org/wiki/Base64 for more details).

The JSON payload
looks something like this:

``` json
{
  "requests": [
    {
      "image": {
        "content": <base64-encoded-image>
      },
      "features": [
        {
          "type": "DOCUMENT_TEXT_DETECTION"
        }
      ]
    }
  ]
}
```

Where
`<base64-encoded-image>`
is an encoding
of our image as text.

Luckily,
we don’t have to figure out
how to do the encoding ourselves.
The R package
{base64enc}
(Urbanek (2015))
can do the work for us.

The
`document_text_detection`
function below
generates
a request
of the right format
given the path
to an image.

It uses
`base64enc::base64encode`
to compute a base64 encoding
of the image
specified by the input path.

``` r
document_text_detection <- function(image_path) {
  list(
    image = list(
      content = base64enc::base64encode(image_path)
    ),
    features = list(
      type = "DOCUMENT_TEXT_DETECTION"
    )
  )
}
```

It then packs
the resulting encoding
into a list
which can be converted
into JSON before
being posted.

As we will
be using
{httr}
(Wickham (2020))
we don’t even have to worry
about doing the conversion
to JSON.
{httr} will do that
automatically by using
{jsonlite}
(Ooms (2014))
when we make our request.

``` r
dtd_001 <- document_text_detection("~/workspace/baree-handwriting-scans/001.png")
```

Be wary of inspecting the return value
of this function call.
It contains a huge JSON string
and R might take a very long time
to output the string
to the screen.

You can use `substr`
to inspect part of it,
if you really want.

``` r
substr(dtd_001, 1, 200)
#> [1] "list(content = \"iVBORw0KGgoAAAANSUhEUgAAE2EAABtoCAIAAAA8pmPCAAAAA3NCSVQICAjb4U/gAAAACXBIWXMAAFxGAABcRgEUlENBAAAgAElEQVR4nOzdwW7aQBRA0dB/9E8yH+kuUC1qCJiUxFx6zgIJMRo/GxaJzBWH4/E4xvj4+Dg9nkzTNE3T+dPVgu3O"
#> [2] "list(type = \"DOCUMENT_TEXT_DETECTION\")"
```

One pitfall
to be wary of
is accidentally
base64encoding the path to a file
instead of the file itself.
If the response from the
Vision API has error messages
containing paths
then that is likely to be the cause.

## Posting requests to Vision API

Now we can use
`httr:POST`
from {httr}
to post our request
to the Vision API.

`httr::POST`
requires at least
`url`
and
`body`
arguments.

`url`
is the webpage
to be retrieved.
In this case
`"https://vision.googleapis.com/v1/images:annotate"`

`body`
is the
request payload.
In this case
a named list
with one element
named `requests`
whose value is a list
of request objects.

As well as the
required arguments
we also have
to tell the server
that the content of our
request is JSON.
We do this
by adding
“Content-Type: application/json”
to the header
of our request.
`httr::POST`
will do it for us
if we
pass a call
to
`httr::content_type_json()`
as one of the
optional arguments.

The Vision API documentation
says that for a request
to be accepted
it must have
an
`Authorization = "Bearer <GCLOUD_ACCESS_TOKEN>"`
header.
We can add the header
using the
`httr::add_headers`
function.

``` r
httr::add_headers(
    "Authorization" = paste("Bearer", Sys.getenv("GCLOUD_ACCESS_TOKEN"))
)
```

Here we have used
`Sys.getenv("GCLOUD_ACCESS_TOKEN")`
to obtain the value
of our access token.

The
`post_vision`
function below
takes a requests list
as output
and returns
the response
from Vision API’s
annotation endpoint.

``` r
post_vision <- function(requests) {
  httr::POST(
    url = "https://vision.googleapis.com/v1/images:annotate",
    body = requests,
    encode = "json",
    httr::content_type_json(),
    httr::add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("GCLOUD_ACCESS_TOKEN"))
    )
  )
}
```

Now we are ready
to make our first request.

We have to call
`post_vision`
with a list of requests.
In our case
we only have one request
`dtd_001`
which we created earlier
by calling
`document_text_detection`
with the path
to our image.
But
`post_vision`
excepts a list
so we have to
pack our single
request inside a list first.

``` r
l_r_001 <- list(requests = dtd_001)

r_001 <- post_vision(l_r_001)
```

Calling
`post_vision`
sends our image
to Vision API
and returns the response.

Depending on the
number of images
in the `requests` list
the above call to `POST`
may take a few seconds
to return a response.

Once it has,
you can use
`httr::status_code`
to check that
a valid response
was received
(value should be 200).

``` r
httr::status_code(r_001)
#> [1] 200
```

If you get a 401 instead
then inspect r\_001.
If you see “ACCESS\_TOKEN\_EXPIRED”
under “error” -&gt; “details”
then you might just have to rerun
the gcloud tool to generate
a new access token
(section 4. in the Appendix).

Next
we explain
how to interpret
a valid response.

## Getting text from the response

If the status code
is 200 then you
can use `httr::content`
to extract the content
of the response.

``` r
content_001 <- httr::content(r_001)
```

The response content
contains a lot
of information.
We are mainly interested
in the text content,
which is contained
in the `responses` object
as `fullTextAnnotation`.

``` r
baree_hw_001 <- content_001$responses[[1]]$fullTextAnnotation$text
cat(baree_hw_001)
#> a
#> vast
#> fear
#> To Parce, for many days after he was
#> born, the world was a
#> gloony cavern.
#> During these first days of his life his
#> home was in the heart of a great windfall
#> where aray wolf, his blind mother, had found
#> a a safe nest for his hahy hood, and to which
#> Kazan, her mate, came only now and then ,
#> his eyes gleaming like strange balls of greenish
#> fire in the darknen. It was kazan's eyes that
#> gave
#> do Barce his first impression of something
#> existing away from his mother's side, and they
#> brought to him also his discovery of vision. He
#> could feel, he could smell, he could hear - but
#> in that black pirt under the fallen timher he
#> had never seen until the
#> eyes
#> came. At first
#> they frightened nin; then they puzzled him , and
#> bis Heer changed to an immense ceniosity, the world
#> be looking foreight at them when all at once
#> they world disappear. This was when Kazan turned
#> his head. And then they would flash hach at him
#> again wt of the darknen with such startling
#> Suddenness that Baree world involuntanty Shrink
#> closer to his mother who always treunded and
#> Shivered in a strenge way when Kazan came in.
#> Barce, of course, would never know their story. He
#> world never know that Gray Wolf, his mother, was
#> a full-hlooded wolf, and that Kazan, his father,
#> was a dog. In hin nature was already
#> nature was already beginning
#> its wonderful work, but it world never go beyind
#> cerria limitations. It wald tell him, in time, ,
#> that his heavtiful wolf - mother was blind, hur
#> he world never know of that terrible hattle between
#> Gray Wolf and the lynx in which his mother's sight
#> had been destroyed Nature could tell hin gatting
#> nothing
#> +
#> а
#> (
```

This is slightly disappointing.
Only some of the text is readable.
But this is only one page.
Maybe things would be better
for someone with better handwriting.

In the next section we try
to quantify how close this
text is to the original text.

## How well does it work?

To compare the results
of extracting the text
of one page of handwriting
we first
download the original text
from Project Gutenberg
using the
{gutenbergr}
(Robinson (2020))
package.

``` r
baree <- gutenbergr::gutenberg_download(4748, mirror = "http://www.mirrorservice.org/sites/ftp.ibiblio.org/pub/docs/books/gutenberg/")
```

If you get an error here,
try a different mirror.
(see gutenbergr docs)

With some manual inspection
we can figure out
the substring
of the downloaded text
corresponding to the handwritten page.

``` r
baree_tx <- paste(baree$text[96:148], collapse = " ")
cat(baree_tx_001 <- stringr::str_sub(baree_tx, 1, 1597))
#> To Baree, for many days after he was born, the world was a vast gloomy cavern.  During these first days of his life his home was in the heart of a great windfall where Gray Wolf, his blind mother, had found a safe nest for his babyhood, and to which Kazan, her mate, came only now and then, his eyes gleaming like strange balls of greenish fire in the darkness. It was Kazan's eyes that gave to Baree his first impression of something existing away from his mother's side, and they brought to him also his discovery of vision. He could feel, he could smell, he could hear--but in that black pit under the fallen timber he had never seen until the eyes came. At first they frightened him; then they puzzled him, and his fear changed to an immense curiosity. He would be looking straight at them, when all at once they would disappear. This was when Kazan turned his head. And then they would flash back at him again out of the darkness with such startling suddenness that Baree would involuntarily shrink closer to his mother, who always trembled and shivered in a strange sort of way when Kazan came in.  Baree, of course, would never know their story. He would never know that Gray Wolf, his mother, was a full-blooded wolf, and that Kazan, his father, was a dog. In him nature was already beginning its wonderful work, but it would never go beyond certain limitations. It would tell him, in time, that his beautiful wolf mother was blind, but he would never know of that terrible battle between Gray Wolf and the lynx in which his mother's sight had been destroyed. Nature could tell him nothing
```

Now using the
{stringdist}
(der Loo (2014))
package we can calculate
the edit distance
from the first page
scanned from my handwriting
and the string
extracted from the
Project Gutenberg text.

``` r
stringdist::stringdist(baree_hw_001, baree_tx_001, method = "lv")
#> [1] 174
```

So apparently we could turn
page of handwriting to match
the text from
Project Gutenberg
with 174 edits.
Quite a lot for one page!

Here we used the default method
optimal string alignment
or restricted Damerau-Levenshtein distance
(method = “osa”)
from
{stringdist}
to measure edit distance.
But the result is the same
if we use
Levenshtein distance (method = “lv”)
or
Full Damerau-Levenshtein distance (method = “dl”).

# Handling multiple pages

It is possible to send a document to the vision API which
has multiple pages. Below we describe a different approach
based on sending a request based on multiple images.

## Build a request based on multiple images

To generate the
complete requests object
we iterate over
all scans in the `scans_folder`
using `purrr::map`.

``` r
scans_folder <- "~/workspace/baree-handwriting-scans"

scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)

response <- post_vision(list(requests = purrr::map(scans, document_text_detection)))
```

Again we can check to make sure that
we received a valid response
before opening it
and seeing what is inside.

``` r
httr::status_code(response)
#> [1] 401
```

Inside is a list of responses
and we want to go through each
response and extract the
`fullTextAnnotation`
list.
This can be done with
`purrr::map`.

``` r
responses_annotations <- purrr::map(httr::content(response)$responses, "fullTextAnnotation")
```

Finally we need to reach inside
those annotations and pull out
any `text`.
As we are expecting text
we can use `purrr::map_chr`.

``` r
purrr::map_chr(responses_annotations, "text")
#> character(0)
```

Lettuce put all of this together in a function
whose input is a path to a folder containing
images and whose return value is the text contained
in all of those images.

``` r
folder_to_txt <- function(scans_folder) {
  scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)
  response <- post_vision(list(requests = purrr::map(scans, document_text_detection)))
  responses_annotations <- purrr::map(httr::content(response)$responses, "fullTextAnnotation")
  purrr::map_chr(responses_annotations, "text")
}
```

``` r
baree_hw <- paste(folder_to_txt(scans_folder), collapse = " ")
```

# How well does it work?

As we did before we can calculate the edit distance
from the original text.

``` r
stringdist::stringdist(baree_hw, baree_tx)
#> [1] 446
```

That’s quite a high number but how does it compare?

There are a couple of things we could compare it to.
We could create a random string
of the same length as the Project Gutenberg
text and calulcate the edit distance.

``` r
stringdist::stringdist(paste(sample(c(letters, " "), stringr::str_length(baree_tx), replace = TRUE), collapse = ""), baree_tx)
#> [1] 2887
```

Hardly surprising but nonetheless reassuring that this
number is much higher.

We could also scan the handwriting using Tesseract
and compare the edit distance to the output
from Google Vision.

``` r
folder_to_txt <- function(scans_folder) {
  eng <- tesseract::tesseract("eng")
  scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)
  purrr::map(scans, tesseract::ocr, engine = eng)
}

baree_hw_ts <- folder_to_txt(scans_folder)

baree_hw_ts <- paste(baree_hw_ts, collapse = " ")
baree_hw_ts <- stringr::str_replace_all(baree_hw_ts, "\n", " ")
```

``` r
stringdist::stringdist(baree_hw_ts, baree_tx)
#> [1] 1461
```

So Vision API does much better than Tesseract
according to this insignifant little test.
But maybe there are ways to configure Tesseract
to handle hadnwriting better. Tesseract certainly
performs incredibly well with typewritten text.
So one solution is to swap pen or pencil for
typewriter. Of course then one is faced with
carrying a typewriter everywhere and sourcing
supplies of ribbon.

Is that a good method to measure the distance?

# Appendix (Google Cloud Platform)

https://cloud.google.com/vision/docs/setup

steps 0 - 2 only have to be done once.

step 3 only needs to be done once and then
whenever the key expires.

If you already have the app and service account
then jump to step 3.

If you already have the private key as well
jump to setp 4.

## 0. Install the cloud SDK

## 1. Create app

First you need to create a GCP project and enable
Vision API for that project.

## 2. Create service account

Then you need to create a service account

## 3. Download private key

and download a private keydd
to location `<PATH_TO_PRIVATE_KEY>`

## 4. use glcoud tool to get access token

    $ export GOOGLE_APPLICATION_CREDENTIALS=<PATH_TO_PRIVATE_KEY>
    $ gcloud auth application-default print-access-token
    <ACCESS_TOKEN>.....................................
    ...................................................
    ...................................................

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-derlooStringdistPackageApproximate2014" class="csl-entry">

Loo, M.P.J. van der. 2014. “The Stringdist Package for Approximate String Matching.” *The R Journal* 6 (1): 111–22. <https://CRAN.R-project.org/package=stringdist>.

</div>

<div id="ref-oomsJsonlitePackagePractical2014" class="csl-entry">

Ooms, Jeroen. 2014. “The Jsonlite Package: A Practical and Consistent Mapping Between JSON Data and r Objects.” *arXiv:1403.2805 \[Stat.CO\]*. <https://arxiv.org/abs/1403.2805>.

</div>

<div id="ref-robinsonGutenbergrDownloadProcess2020" class="csl-entry">

Robinson, David. 2020. “Gutenbergr: Download and Process Public Domain Works from Project Gutenberg.” Manual.

</div>

<div id="ref-urbanekBase64encToolsBase642015" class="csl-entry">

Urbanek, Simon. 2015. “Base64enc: Tools for Base64 Encoding.” Manual. <http://www.rforge.net/base64enc>.

</div>

<div id="ref-wickhamHttrToolsWorking2020" class="csl-entry">

Wickham, Hadley. 2020. “Httr: Tools for Working with URLs and HTTP.” Manual.

</div>

</div>
