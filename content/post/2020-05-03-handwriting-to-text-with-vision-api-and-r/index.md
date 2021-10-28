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
- id: wickhamUsethisAutomatePackage2021
  author:
    - family: Wickham
      given: Hadley
    - family: Bryan
      given: Jennifer
  genre: manual
  issued:
    - year: 2021
  title: 'usethis: Automate package and project setup'
  type: report
- id: oomsTesseractOpenSource2021
  author:
    - family: Ooms
      given: Jeroen
  genre: manual
  issued:
    - year: 2021
  title: 'tesseract: Open source OCR engine'
  type: report
---

In this post I’ll show you how to use Google Cloud Platform’s
Vision API to extract text from images in R.

I’m mostly interested in the case when the
text being extracted is handwritten.
For typewritten text,
I use
[Tesseract](https://github.com/tesseract-ocr).

This post began
as some notes to myself
as someone who writes
a lot of other notes by hand
and sometimes like to move
those other notes
onto the computer.

Is it feasible to use OCR software for such a task?
Tesseract, which works
very well for OCR of typed characters does not seem to
do very well with handwriting.
Google’s Vision API,
on the other hand,
is able to extract handwritten text
from images.
Does it do that well enough to be useful?

# Preparation

Before doing anything in R
you must
create a project on
Google Cloud Platform (GCP)
and enable Vision API.

In the appendix
I have written
some brief notes
about how to do this
but if you are using GCP
for the first time
I recommend
following a tutorial
like the one at
https://cloud.google.com/vision/docs/setup
instead.

After creating your GCP project
you should find yourself
the proud owner
of a shiny new access token.

To run any of the code below
we need to tell R
what the access token is.
But we have to
be careful not to hardcode
our secret token anywhere
in our code
because the token
gives its owner the power
to make API requests
which can incur costs.

Instead we define
an environment variable
`GCLOUD_ACCESS_TOKEN`
with out secret token
and access the value
of the environment variable
in our code.

One of the easiest ways
to define an environment variable
in R is to use
the
{usethis}
(Wickham and Bryan (2021))
package to edit
`.Renviron`,
at project
or user scope.

``` r
usethis::edit_r_environ(scope = "user")
```

Put into the file
that opens in RStudio
something like this:

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
`.Renviron` you need to restart R.
Then you can
use
`Sys.getenv`
to check
that the environment variable
is equal to the access token.

``` r
Sys.getenv("GCLOUD_ACCESS_TOKEN")
```

The output here should
be your access token.
If it’s an empty string
then you might need
to restart R.

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
It then packs
the resulting encoding
into a list
which can be converted
into JSON before
being posted.

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
encoding the path to a file
instead of the contents of the file itself.
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
as input
and returns
the response
from Vision API’s
annotation endpoint
as a list.

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
to use
`post_vision`
to make our first request.

`post_vision`
expects a
list of requests
as input.
In our case
we only have one request
`dtd_001`
which we created earlier
by calling
`document_text_detection`
with the path
to our image.
Nevertheless,
we still have to
pack our single
request inside a list first.

``` r
l_r_001 <- list(requests = dtd_001)
```

Calling
`post_vision`
sends our image
to Vision API
and returns the response.

``` r
r_001 <- post_vision(l_r_001)
```

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
#> [1] 401
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
can use
`httr::content`
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
in the
`responses`
object
as
`fullTextAnnotation`.

``` r
baree_hw_001 <- content_001$responses[[1]]$fullTextAnnotation$text
cat(baree_hw_001)
```

Some of the text is readable
but there is a lot that
needs to be done
to fix all of the errors.
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
we can find
the substring
of the downloaded text
corresponding to our handwritten page.

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
between the text
extracted from the handwritten page
by Vision API
and the string
extracted from the
Project Gutenberg text.

``` r
stringdist::stringdist(baree_hw_001, baree_tx_001, method = "lv")
#> numeric(0)
```

Apparently we could change
the handwriting based text
page of handwriting to match
the text from Project Gutenberg
with 174 changes.
Quite a lot for one page!
But we have to bear in mind
that edit distance is not
quite the same as the number
of changes you would
need to make to fix
the document yourself.
You could use spell check tools
to fix some errors quickly
and
use search-and-replace
to remove systematic errors
like non-alphabetic characters
(assuming your text is entirely alphabetic)
or additional spacing.

In calculating edit distance
we used the default
optimal string alignment method
from
{stringdist}.
But the result is the same
if we use different methods like
Levenshtein distance (method = “lv”)
or
Full Damerau-Levenshtein distance (method = “dl”).

# Handling multiple pages

It is possible to send a document to the vision API which
has multiple pages. Below we describe a different approach
to handling multiple pages
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

Notice that
even though we have
multiple images
we still only make one request.
The JSON payload
contains multiple images.

Again we check to make sure that
we received a valid response
before opening it
to see what’s inside.

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
`purrr::map`
which has a nice feature
that if a string
is given for the function argument
then `purrr::map` converts
that string into an extractor function
which will pull out
elements of the list argument
having that name.

``` r
responses_annotations <- purrr::map(httr::content(response)$responses, "fullTextAnnotation")
```

Using the same feature again
we reach inside
the annotations
to pull out
any
`text`
elements.

``` r
purrr::map_chr(responses_annotations, "text")
#> character(0)
```

Using
`purrr::map_chr`
instead of
`purrr:map`
here returns
a character vector
instead of a list.

The
`folder_to_chr`
function below
puts all of these steps together.
The input is a path
to a folder containing images
whose text we want to extract.
The return value
is a string
containing all text
contained in those images.
This presumes that files
are organised in the right order
in the input folder.

``` r
folder_to_chr <- function(scans_folder) {
  scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)
  response <- post_vision(list(requests = purrr::map(scans, document_text_detection)))
  responses_annotations <- purrr::map(httr::content(response)$responses, "fullTextAnnotation")
  purrr::map_chr(responses_annotations, "text")
}
```

Now we can convert
all the handwritten pages
of the first chapter of Baree.

``` r
baree_hw <- paste(folder_to_chr(scans_folder), collapse = " ")
```

# How well does it work?

As before we calculate the edit distance
from the original text.

``` r
stringdist::stringdist(baree_hw, baree_tx)
#> [1] 446
```

That seems like a high number
but it’s hard to know
without something to compare it against.

How does is compare,
for example,
to the edit distance
between a random string
the same length
as the target text
and the target text itself.

``` r
stringdist::stringdist(paste(sample(c(letters, " "), stringr::str_length(baree_tx), replace = TRUE), collapse = ""), baree_tx)
#> [1] 2864
```

It’s hardly surprising that this is
a much higher number.

Another comparison worth making
is against the result
of using Tesseract
to extract the text
of the same handwritten pages.

Fortunately,
the
{tesseract}
(Ooms (2021))
R package makes this very easy.

``` r
folder_to_chr_ts <- function(scans_folder) {
  eng <- tesseract::tesseract("eng")
  scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)
  paste(purrr::map(scans, tesseract::ocr, engine = eng), collapse = " ")
}

baree_hw_ts <- folder_to_chr_ts(scans_folder)
```

``` r
stringdist::stringdist(baree_hw_ts, baree_tx)
#> [1] 1461
```

So Vision API does much better than Tesseract
according to this particular little test.
But this is probably not a fair comparison.
Tesseract doesn’t claim to be able to
extract text from images of handwriting.
Furthermore,
it might be possible to configure
Tesseract in a way that improves
the results
or to modify the input images
to make them better suited to Tesseract.
For my purposes I just wanted to see
if using Vision API made it possible
to work with handwritten pages
in this way.
While it seems promising I can tell
from this little experiment that I’d
probably spend longer editing the resulting
texts to corrects errors than I would
spend typing them.

# Appendix (Google Cloud Platform)

This appendix is a reference
to remind myself what steps
to follow.

A better resource
if you haven’t done this before is:
https://cloud.google.com/vision/docs/setup

-   0 - 2 only have to be done once.
-   3 only needs to be done once
    unless the private key has expired.
-   If you have already
    created a project
    and service account
    then jump to step 3.
-   If you already have the private key as well
    jump to step 4.

## 0. Install the cloud SDK

We need the `glcoud` tool
to configure authentication.

The instructions are here:
https://cloud.google.com/sdk/docs/install

## 1. Create project

First you need to create a GCP project and enable
Vision API for that project.

You will have to setup billing when creating
the project if you haven’t done so before.

Go to the Project Selector:
https://console.cloud.google.com/projectselector2/home/dashboard
and select “Create Project”

Give your project a name
and click “Create.”

Wait for the circly thing to spin around forever.

Eventually the Project Dashboard appears.
At the time of writing
somewhere in the bottom-left of the dashboard
is a “Getting Started” panel
containing a link named
“Explore and enable APIs.”
Click on it.

You will be transported to the API dashboard.
At the top you should see
“+ ENABLE APIs AND SERVICES.”
Click on that.

Now you get a search dialog.

Type “vision” and press enter.

Select “Cloud Vision API” and on the page that appears
click the “Enable” button.

What a palaver.

## 2. Create service account

Then you need to create a service account.

This is a good point to just give up.

Strictly speaking this isn’t necessary
but it does seem to be the most straightforward way
of enable authentication for your project.

Click the three lines (what are those called again)
to open the menu on the left
of the screen.

Scroll down to “IAM & Admin”
and select “Service Accounts.”

Click on “Create Service Account.”

Give your account a name.

Click “Create and continue”

XXX HERE XXX

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

<div id="ref-oomsTesseractOpenSource2021" class="csl-entry">

———. 2021. “Tesseract: Open Source OCR Engine.” Manual.

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

<div id="ref-wickhamUsethisAutomatePackage2021" class="csl-entry">

Wickham, Hadley, and Jennifer Bryan. 2021. “Usethis: Automate Package and Project Setup.” Manual.

</div>

</div>
