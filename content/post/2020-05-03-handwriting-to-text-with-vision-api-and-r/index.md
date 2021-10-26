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
output:
  blogdown::html_page:
    toc: true
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
---

In this post we describe how to use Google Cloud Platform,
in particular the Vision API, to extract text from images.

Of particular interest in this post is the case when the
text being extracted is handwriting. These are really
notes to myself as someone who writes a lot of notes by
hand and sometimes like to move those notes onto the computer.
Is it feasible to use OCR software? Tesseract, which works
very well for OCR of typed characters does not seem to
do very well with handwriting. Google Vision API,
on the other hand, is able to extract text from handwriting.
But does it do it well enough to be useful? That’s what
we are interested in here.

# Preparation

The first steps,
before doing anything in R,
involve creating a project on
Google Cloud Platform (GCP)
and enabling the Vision API
for this app.

In the appendix below there are some
notes on how to do this
but if you are using GCP for the first
time it is probably better
to follow a tutorial instead.

When your app has been created
and you have created a service account
and setup payment
and authentication
you will find yourself
the proud owner
of an access token.

So that R knows that the token is you have to
define the `GCLOUD_ACCESS_TOKEN` access variable.

One of the easiest ways to do this is to use
the usethis package to edit .Renviron, either
at project score or user scope.

``` r
usethis::edit_r_environ(scope = "user")
```

After defining your access token in your
.Renviron you need to restart R. Then you
can check that the environment variable now
is defined to be equal to the access token.

``` r
Sys.getenv("GCLOUD_ACCESS_TOKEN")
```

Now we can start extracting text from an image.
In the next section I show how you can
extract text from a single image file.
In the section following that I show
how you can extract text from multiple images.

# Extract handwriting from one image

In this section
and the following ones
I will make use of some images
of my own handwriting.
So I can compare the results
of the OCR
against a known text
I have written out by hand
a few pages of the novel
“Baree, Son of Kazan” by James Oliver Curwood
(sequel to “Kazan”)
whose original text
is available on Project Gutenberg:
https://www.gutenberg.org/ebooks/4748
https://www.gutenberg.org/ebooks/53929

## Creating document text detection requests

To use the Vision API
we will post our images via http to
`https://vision.googleapis.com/v1/images:annotate`
with a JSON payload
that includes the images encoded
as text using the Base64
encoding scheme.
(see https://en.wikipedia.org/wiki/Base64 for more details).

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

Luckily,
we don’t have to figure out
any of the details of doing the encoding ourselves
because there is an R package
(Urbanek (2015))
`base64enc`
that will do the work for us.

With a function
in R we can generate
a request based
on a specific image.

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

The input to this
function is a path
to an image file.
The function takes
that path
and uses
`base64enc::base64encode`
to compute a base64 encoding
of the image.
It then packs
the resulting encoding
into a list
which will be converted
into JSON automatically
by the `httr` package
(using the `jsonlite` package)
when we make our request.

Images have to be less than 10MB.

In fact the whole request has to be at most 10MB?

## Post requests to our app

Next we use `httr:POST`
from the httr package
Wickham (2020)
to post our request object
to the Vision API.

There are two arguments to
`httr::POST`
that are required:
`url`
and
`body`.

`url` is the webpage
to retrieve
which in our case is
`"https://vision.googleapis.com/v1/images:annotate"`

`body` is the
request payload.
In our case,
we have a named list
called `requests`.

As well as the required
arguments we also need
to tell the server
that the content of our
request is JSON
by adding
“Content-Type: application/json”
to the header
of our request.
We can do this
with
`httr::POST`
by adding a call
to
`httr::content_type_json()`
to the `...` parameters.

In the documentation
for the Vision API
we will also see
that for the request
to be accepted
it must have
a header
`Authorization = "Bearer <ACCESS_TOKEN>"`
where <ACCESS_TOKEN>
is the value
of our
`GCLOUD_ACCESS_TOKEN`
environment variable.

``` r
library(httr)

post_vision <- function(requests) {
  POST(
    url = "https://vision.googleapis.com/v1/images:annotate",
    body = requests,
    encode = "json",
    content_type_json(),
    add_headers(
      "Authorization" = paste("Bearer", Sys.getenv("GCLOUD_ACCESS_TOKEN"))
    )
  )
}
```

Now we can make our first request by calling
the
`post_vision`
function
with a list of requests.
Here we only have one request,
made my calling
`document_text_detection`
with the path
to our image.

``` r
r_001 <- post_vision(list(requests = document_text_detection("~/workspace/baree-handwriting-scans/001.png")))
```

HELLO.

## Now parse out the results

Depending on the
number of images
in the `requests` list
the above call to `POST`
may take a few seconds
to return a response.

Once it has,
you can use `httr::status_code`
to check that
a valid response
was received
(value should be 200).

``` r
status_code(r_001)
#> [1] 200
```

If the status code
is 200 then you
can use the `httr::content`
to extract the content
of the response.

The response content
contains a lot
of information.
It is a named list
representation of
the object described here:

We are mainly interested
in the text content,
which is contained
in the `responses` object
as `fullTextAnnotation`.

``` r
content(r_001)$responses[[1]]$fullTextAnnotation$text
#> [1] "a\nvast\nfear\nTo Parce, for many days after he was\nborn, the world was a\ngloony cavern.\nDuring these first days of his life his\nhome was in the heart of a great windfall\nwhere aray wolf, his blind mother, had found\na a safe nest for his hahy hood, and to which\nKazan, her mate, came only now and then ,\nhis eyes gleaming like strange balls of greenish\nfire in the darknen. It was kazan's eyes that\ngave\ndo Barce his first impression of something\nexisting away from his mother's side, and they\nbrought to him also his discovery of vision. He\ncould feel, he could smell, he could hear - but\nin that black pirt under the fallen timher he\nhad never seen until the\neyes\ncame. At first\nthey frightened nin; then they puzzled him , and\nbis Heer changed to an immense ceniosity, the world\nbe looking foreight at them when all at once\nthey world disappear. This was when Kazan turned\nhis head. And then they would flash hach at him\nagain wt of the darknen with such startling\nSuddenness that Baree world involuntanty Shrink\ncloser to his mother who always treunded and\nShivered in a strenge way when Kazan came in.\nBarce, of course, would never know their story. He\nworld never know that Gray Wolf, his mother, was\na full-hlooded wolf, and that Kazan, his father,\nwas a dog. In hin nature was already\nnature was already beginning\nits wonderful work, but it world never go beyind\ncerria limitations. It wald tell him, in time, ,\nthat his heavtiful wolf - mother was blind, hur\nhe world never know of that terrible hattle between\nGray Wolf and the lynx in which his mother's sight\nhad been destroyed Nature could tell hin gatting\nnothing\n+\nа\n(\n"
```

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
library(purrr)

scans_folder <- "~/workspace/baree-handwriting-scans"

scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)

response <- post_vision(list(requests = map(scans, document_text_detection)))
```

Again we can check to make sure that
we received a valid response
before opening it
and seeing what is inside.

``` r
status_code(response)
#> [1] 200
```

Inside is a list of responses
and we want to go through each
response and extract the
`fullTextAnnotation`
list.
This can be done with
`purrr::map`.

``` r
responses_annotations <- map(content(response)$responses, "fullTextAnnotation")
```

Finally we need to reach inside
those annotations and pull out
any `text`.
As we are expecting text
we can use `purrr::map_chr`.

``` r
map_chr(responses_annotations, "text")
#> [1] "a\nvast\nfear\nTo Parce, for many days after he was\nborn, the world was a\ngloony cavern.\nDuring these first days of his life his\nhome was in the heart of a great windfall\nwhere aray wolf, his blind mother, had found\na a safe nest for his hahy hood, and to which\nKazan, her mate, came only now and then ,\nhis eyes gleaming like strange balls of greenish\nfire in the darknen. It was kazan's eyes that\ngave\ndo Barce his first impression of something\nexisting away from his mother's side, and they\nbrought to him also his discovery of vision. He\ncould feel, he could smell, he could hear - but\nin that black pirt under the fallen timher he\nhad never seen until the\neyes\ncame. At first\nthey frightened nin; then they puzzled him , and\nbis Heer changed to an immense ceniosity, the world\nbe looking foreight at them when all at once\nthey world disappear. This was when Kazan turned\nhis head. And then they would flash hach at him\nagain wt of the darknen with such startling\nSuddenness that Baree world involuntanty Shrink\ncloser to his mother who always treunded and\nShivered in a strenge way when Kazan came in.\nBarce, of course, would never know their story. He\nworld never know that Gray Wolf, his mother, was\na full-hlooded wolf, and that Kazan, his father,\nwas a dog. In hin nature was already\nnature was already beginning\nits wonderful work, but it world never go beyind\ncerria limitations. It wald tell him, in time, ,\nthat his heavtiful wolf - mother was blind, hur\nhe world never know of that terrible hattle between\nGray Wolf and the lynx in which his mother's sight\nhad been destroyed Nature could tell hin gatting\nnothing\n+\nа\n(\n"
#> [2] "7\n9\n49\n7\nof Kazan's merciless vengeance 1 of the wonderful\nyears of their matehood of their loyalty, their\nShenge adventures in the great Canadian wilderness\ncit'culd make him arby a son of hazar.\nBut at first, and for many days, it was all\nMother. Even after his eyes opened wide and he\nhad pund his legs so that he could shonhce around\na little in the darkness, nothing existed ar buree\nfor\nhut his mother. When he was old enough to he\n.\nplaying with Shicks and mess art in the sunlight,\nhe still did not know what she looked like. But\nto him she was big and soft and warm, and she\nhicked his face with her tongue, and talked to him\nin a gentle, whimpening way that at lost made\nhim find his own voice in a faint, squeaky yap.\nAnd then came that wonderful day when the\ngreenish balls of fire that were kažan's eyes cancie\nnearer and nearer, a little at a tine, ,\ncarbiesky. Hereto pore Gray Wolf had warned hin\nhach. To he alone was the first law of her wild\nbreed during mothering time. A low snart from her\n. A\nthroat, ånd Kazan' had always stopped. But\nănd\non this day the snart did not come in aray\nWolf's throat it died away in a low, whimpering\nscond. A note of loneliness, of\ni 아\ngreat yearniny _“It's all night law,\" she was\nť keys, of a\nnow\nsaying to kázan; and katan\npowsing for a moment\nreplied with an answłni\nwswering\ndeep in his throat.\nStill slowly, as it not quite sure of what he\nЕ\nwould find, Kazan came to them, and Baree\nsnuggled closer to his mother\nas he dropped down heavily on his belly close to\naray Wolf. He was unafraid\nand nightily\nand\nvery\n.\nC\nto make ure -\nnote\nHe heard kazan\n"
```

Lettuce put all of this together in a function
whose input is a path to a folder containing
images and whose return value is the text contained
in all of those images.

``` r
folder_to_txt <- function(scans_folder) {
  scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)
  response <- post_vision(list(requests = map(scans, document_text_detection)))
  responses_annotations <- map(content(response)$responses, "fullTextAnnotation")
  map_chr(responses_annotations, "text")
}
```

``` r
folder_to_txt(scans_folder)
#> [1] "a\nvast\nfear\nTo Parce, for many days after he was\nborn, the world was a\ngloony cavern.\nDuring these first days of his life his\nhome was in the heart of a great windfall\nwhere aray wolf, his blind mother, had found\na a safe nest for his hahy hood, and to which\nKazan, her mate, came only now and then ,\nhis eyes gleaming like strange balls of greenish\nfire in the darknen. It was kazan's eyes that\ngave\ndo Barce his first impression of something\nexisting away from his mother's side, and they\nbrought to him also his discovery of vision. He\ncould feel, he could smell, he could hear - but\nin that black pirt under the fallen timher he\nhad never seen until the\neyes\ncame. At first\nthey frightened nin; then they puzzled him , and\nbis Heer changed to an immense ceniosity, the world\nbe looking foreight at them when all at once\nthey world disappear. This was when Kazan turned\nhis head. And then they would flash hach at him\nagain wt of the darknen with such startling\nSuddenness that Baree world involuntanty Shrink\ncloser to his mother who always treunded and\nShivered in a strenge way when Kazan came in.\nBarce, of course, would never know their story. He\nworld never know that Gray Wolf, his mother, was\na full-hlooded wolf, and that Kazan, his father,\nwas a dog. In hin nature was already\nnature was already beginning\nits wonderful work, but it world never go beyind\ncerria limitations. It wald tell him, in time, ,\nthat his heavtiful wolf - mother was blind, hur\nhe world never know of that terrible hattle between\nGray Wolf and the lynx in which his mother's sight\nhad been destroyed Nature could tell hin gatting\nnothing\n+\nа\n(\n"
#> [2] "7\n9\n49\n7\nof Kazan's merciless vengeance 1 of the wonderful\nyears of their matehood of their loyalty, their\nShenge adventures in the great Canadian wilderness\ncit'culd make him arby a son of hazar.\nBut at first, and for many days, it was all\nMother. Even after his eyes opened wide and he\nhad pund his legs so that he could shonhce around\na little in the darkness, nothing existed ar buree\nfor\nhut his mother. When he was old enough to he\n.\nplaying with Shicks and mess art in the sunlight,\nhe still did not know what she looked like. But\nto him she was big and soft and warm, and she\nhicked his face with her tongue, and talked to him\nin a gentle, whimpening way that at lost made\nhim find his own voice in a faint, squeaky yap.\nAnd then came that wonderful day when the\ngreenish balls of fire that were kažan's eyes cancie\nnearer and nearer, a little at a tine, ,\ncarbiesky. Hereto pore Gray Wolf had warned hin\nhach. To he alone was the first law of her wild\nbreed during mothering time. A low snart from her\n. A\nthroat, ånd Kazan' had always stopped. But\nănd\non this day the snart did not come in aray\nWolf's throat it died away in a low, whimpering\nscond. A note of loneliness, of\ni 아\ngreat yearniny _“It's all night law,\" she was\nť keys, of a\nnow\nsaying to kázan; and katan\npowsing for a moment\nreplied with an answłni\nwswering\ndeep in his throat.\nStill slowly, as it not quite sure of what he\nЕ\nwould find, Kazan came to them, and Baree\nsnuggled closer to his mother\nas he dropped down heavily on his belly close to\naray Wolf. He was unafraid\nand nightily\nand\nvery\n.\nC\nto make ure -\nnote\nHe heard kazan\n"
```

One pitfall
to be wary of
is accidentally
base64encoding the path to a file
instead of the file itself.
If the response from the
Vision API has
errors that mention
those paths then that is likely to be the cause.

# How well does it work?

The output can contain
a lot of errors.
As a test,
we can take
some pages of text
and write them
out by hand,
scan the resulting
pages
and compare the
OCR of the handwritten
pages against the
original text
or an OCR
of the printed text.

Project Gutenberg
has a lot of computer texts.
I looked for a novel
that I also have a paperback copy
of and chose
James Oliver Curwood’s
“Baree, Son of Kazan.”

I scanned the pages
from the first chapter
of my copy of the novel
and downloaded the text
from Project Gutenberg as well.
Then I wrote out by
hand all of Chapter 1
and scanned the handwritten
pages.

``` r
library(readr)

library(gutenbergr)

baree <- gutenberg_download(4748, mirror = "http://www.mirrorservice.org/sites/ftp.ibiblio.org/pub/docs/books/gutenberg/")

baree_ch_1_gut <- paste(baree$text[96:239], collapse = "")
baree_ch_1_ocr <- paste(responses_text, collapse = "")
```

``` r
library(stringdist)

1 - stringdist(baree_ch_1_gut, baree_ch_1_ocr)/nchar(baree_ch_1_gut)
```

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

<div id="ref-urbanekBase64encToolsBase642015" class="csl-entry">

Urbanek, Simon. 2015. “Base64enc: Tools for Base64 Encoding.” Manual. <http://www.rforge.net/base64enc>.

</div>

<div id="ref-wickhamHttrToolsWorking2020" class="csl-entry">

Wickham, Hadley. 2020. “Httr: Tools for Working with URLs and HTTP.” Manual.

</div>

</div>
