---
title: "(WIP) Extracting Text from Images with Google Vision API and R"
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
    and r objects
    The jsonlite package: A practical and consistent mapping between JSON data
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

In this post I’ll show you
how to use
Google Cloud Platform’s
Vision API
to extract text from images in R.

I’m mostly interested in the case when the
text being extracted is handwritten.
For typewritten text
I use
[Tesseract](https://github.com/tesseract-ocr).

Is it feasible to use OCR software for such a task?
Tesseract works very well
with typed text
but does not seem to handle
handwriting very well.[^1]
Google’s Vision API,
on the other hand,
is able to extract handwritten text
from images.

# Preparation

Before doing anything in R
you must
create a project on
Google Cloud Platform (GCP)
and enable Vision API
for your project.

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
our secret access token
in our source code.
The access token
bestows on its owner
the power to make
API requests
which can incur costs.

To avoid putting
the access token
in your source code
define
an environment variable
`GCLOUD_ACCESS_TOKEN`
containing the access token
and access the value
of the environment variable
in source code
with
`Sys.getenv("GCLOUD_ACCESS_TOKEN")`.

It is possible
to use `Sys.setenv`
to define the environment variable.
A different method
is to define
the environment variable
in an `.Renviron` file.
One benefit of this approach
is that the environment variable
then persists between sessions.

The
{usethis}
(Wickham and Bryan (2021))
package
makes it easy
to edit
`.Renviron`,
at project
or user scope.

``` r
usethis::edit_r_environ(scope = "user")
```

This opens
the user
`.Renviron`
in RStudio.
Edit the file
so that it contains
a line like this:

    GCLOUD_ACCESS_TOKEN=<your access token here>

Be careful not to commit this file
to a Git repository.
Anyone who has the token
can potentially make requests
of your app
and force you to incur costs.

After defining your access token in
`.Renviron`
you must restart R.
After restarting
you should be able to use
`Sys.getenv`
to check
that the environment variable
is now equal to the access token.

``` r
Sys.getenv("GCLOUD_ACCESS_TOKEN")
```

Now we are ready
to begin extracting text from images
in R.

In the next section I’ll show you how to
extract text from a single image file.

Later I’ll show you how to
extract text from multiple images.

# Extracting handwriting from a single image

In this section
and the following ones
I’ll make use of some images
of my own handwriting.

So I can compare
the output
of Vision API
against a known text
I have handwritten
several pages
of
[James Oliver Curwood](https://en.wikipedia.org/wiki/James_Oliver_Curwood)’s
novel
*Baree, Son of Kazan*.
Below, I compare
the results of
extracting text from these
handwritten pages
to the
[text version of the novel from Project Gutenberg.](https://www.gutenberg.org/ebooks/4748)

## Creating document text detection requests

To use Vision API
to extract text from images
we have to
send those images
to the URL
`https://vision.googleapis.com/v1/images:annotate`
in JSON format.
To put images
into JSON
means encoding them
as text.
Vision API requires
images encoded as text
to use the Base64 encoding scheme.
(see
https://en.wikipedia.org/wiki/Base64
for more details).

The JSON payload
of a text detection request
to Vision API
should
look something like this:

``` json
{
  "requests": [
    {
      "image": {
        "content": <encoded-image>
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

Here
`<encoded-image>`
is a Base64 encoding
of the image
we want to extract text from.

Luckily,
we don’t have to figure out
how to do the encoding ourselves.
The R package
{base64enc}
(Urbanek (2015))
will do the work for us.

The
`document_text_detection`
function below
uses
`base64enc::base64encode`
to compute a Base64 encoding
of the image
specified by the input path.
It then packs
the resulting encoding
into a list
of the right format
for converting
to JSON before
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
to JSON ourselves.
{httr} will do it
automatically using
{jsonlite}
(Ooms (2014))
behind-the-scenes
when we make our request.

Now we can use
`document_text_detection`
to create a request
based on the image
located at:
`~/workspace/baree-handwriting-scans/001.png`

``` r
dtd_001 <- document_text_detection("~/workspace/baree-handwriting-scans/001.png")
```

Be wary of inspecting the return value
of this function call.
It contains a huge base64 string
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
then this is a possible cause.

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

As well as those
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
This means
passing a call
to
`httr::content_type_json()`
as one of the
optional arguments
to
`httr::POST`.

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

Here we use
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
In this case
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
request inside a list.

``` r
l_r_001 <- list(requests = dtd_001)
```

Calling
`post_vision`
now
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
#> [1] 200
```

If you get a 401 instead
then inspect r\_001.
If you see
something like this:

    Response [https://vision.googleapis.com/v1/images:annotate]
      Date: 2021-10-29 09:29
      Status: 401
      Content-Type: application/json; charset=UTF-8
      Size: 634 B
    {
      "error": {
        "code": 401,
        "message": "Request had invalid authentication credentials. Expected OAuth 2 acc...
        "status": "UNAUTHENTICATED",
        "details": [
          {
            "@type": "type.googleapis.com/google.rpc.ErrorInfo",
            "reason": "ACCESS_TOKEN_EXPIRED",
            "domain": "googleapis.com",

then you probably have to rerun
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
in the text content
contained
inside
`responses[[1]]`
as
`fullTextAnnotation$text`.

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

Some of the text is readable
but there is much
to be done
to fix all errors.
But this is only one page.
Maybe things would be better
for someone with better handwriting.

In the next section we try
to quantify how close this
text is to the original text
by measuring the
edit distance
to the equivalent
page of text
from Project Gutenberg.

## How well does it work?

To download the original text
from Project Gutenberg
use the
{gutenbergr}
(Robinson (2020))
package.

``` r
baree <- gutenbergr::gutenberg_download(4748)
```

If you get an error here,
try a different mirror.

Using manual inspection
find the substring
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
package calculate
the edit distance
between the text
extracted from the handwritten page
by Vision API
and the string
extracted from the
Project Gutenberg text.

``` r
stringdist::stringdist(baree_hw_001, baree_tx_001, method = "lv")
#> [1] 174
```

Apparently we could change
the handwriting based text
to match
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
Levenshtein distance
(`method = "lv"`)
or
Full Damerau-Levenshtein distance
(`method = "dl"`).

# Handling multiple pages

It is possible to send a multipage document
to Vision API.
Here we describe a different approach
to multipage documents
based on sending requests
containing multiple images.

## Building a request based on multiple images

Put images of all pages
to be converted into the same folder.

Use
`list.files`
with
`full.names = TRUE`
and
`pattern = '*.png'`
(assuming your images are PNG format)
to get a list
of all images.

``` r
scans_folder <- "~/workspace/baree-handwriting-scans"

scans <- list.files(scans_folder, pattern = '*.png', full.names = TRUE)
```

Iterate over the scans
using
`purrr::map`
with
`document_text_detection`
to create a
list of
JSON request objects
one for each page.

``` r
scans_dtd <- purrr::map(scans, document_text_detection)
```

As before,
wrap
this list of requests
in another list
before calling the
`post_vision`
function
to send all
images to Vision API.

``` r
response <- post_vision(list(requests = scans_dtd))
```

Notice that
even though there are
multiple images
we still only make one request.
The JSON payload
contains encodings
of all images.

As before,
check that
a valid response
was received
before opening it up
and looking at what is inside.

``` r
httr::status_code(response)
#> [1] 200
```

Now we can go through
the responses
and extract the
`fullTextAnnotation`
list for each of them.

This can be done with
`purrr::map`
by passing the name
`"fullTextAnnotation"`
as the function argument.

``` r
responses_annotations <- purrr::map(httr::content(response)$responses, "fullTextAnnotation")
```

`purrr::map`
converts
`"fullTextAnnotation"`
into an extractor function
which pulls out
elements of the list argument
having that name.

Using the same feature
we reach into
the annotations
and pull out
any
`text`
elements.
This time using
`purrr::map_chr`
instead of
`purrr:map`
because we are expecting
the output
to be a string.

``` r
purrr::map_chr(responses_annotations, "text")
#> [1] "a\nvast\nfear\nTo Parce, for many days after he was\nborn, the world was a\ngloony cavern.\nDuring these first days of his life his\nhome was in the heart of a great windfall\nwhere aray wolf, his blind mother, had found\na a safe nest for his hahy hood, and to which\nKazan, her mate, came only now and then ,\nhis eyes gleaming like strange balls of greenish\nfire in the darknen. It was kazan's eyes that\ngave\ndo Barce his first impression of something\nexisting away from his mother's side, and they\nbrought to him also his discovery of vision. He\ncould feel, he could smell, he could hear - but\nin that black pirt under the fallen timher he\nhad never seen until the\neyes\ncame. At first\nthey frightened nin; then they puzzled him , and\nbis Heer changed to an immense ceniosity, the world\nbe looking foreight at them when all at once\nthey world disappear. This was when Kazan turned\nhis head. And then they would flash hach at him\nagain wt of the darknen with such startling\nSuddenness that Baree world involuntanty Shrink\ncloser to his mother who always treunded and\nShivered in a strenge way when Kazan came in.\nBarce, of course, would never know their story. He\nworld never know that Gray Wolf, his mother, was\na full-hlooded wolf, and that Kazan, his father,\nwas a dog. In hin nature was already\nnature was already beginning\nits wonderful work, but it world never go beyind\ncerria limitations. It wald tell him, in time, ,\nthat his heavtiful wolf - mother was blind, hur\nhe world never know of that terrible hattle between\nGray Wolf and the lynx in which his mother's sight\nhad been destroyed Nature could tell hin gatting\nnothing\n+\nа\n(\n"
#> [2] "7\n9\n49\n7\nof Kazan's merciless vengeance 1 of the wonderful\nyears of their matehood of their loyalty, their\nShenge adventures in the great Canadian wilderness\ncit'culd make him arby a son of hazar.\nBut at first, and for many days, it was all\nMother. Even after his eyes opened wide and he\nhad pund his legs so that he could shonhce around\na little in the darkness, nothing existed ar buree\nfor\nhut his mother. When he was old enough to he\n.\nplaying with Shicks and mess art in the sunlight,\nhe still did not know what she looked like. But\nto him she was big and soft and warm, and she\nhicked his face with her tongue, and talked to him\nin a gentle, whimpening way that at lost made\nhim find his own voice in a faint, squeaky yap.\nAnd then came that wonderful day when the\ngreenish balls of fire that were kažan's eyes cancie\nnearer and nearer, a little at a tine, ,\ncarbiesky. Hereto pore Gray Wolf had warned hin\nhach. To he alone was the first law of her wild\nbreed during mothering time. A low snart from her\n. A\nthroat, ånd Kazan' had always stopped. But\nănd\non this day the snart did not come in aray\nWolf's throat it died away in a low, whimpering\nscond. A note of loneliness, of\ni 아\ngreat yearniny _“It's all night law,\" she was\nť keys, of a\nnow\nsaying to kázan; and katan\npowsing for a moment\nreplied with an answłni\nwswering\ndeep in his throat.\nStill slowly, as it not quite sure of what he\nЕ\nwould find, Kazan came to them, and Baree\nsnuggled closer to his mother\nas he dropped down heavily on his belly close to\naray Wolf. He was unafraid\nand nightily\nand\nvery\n.\nC\nto make ure -\nnote\nHe heard kazan\n"
```

The
`folder_to_chr`
function below
puts the above steps together.

Input to
`folder_to_chr`
is a path
to a folder of images
whose text we want to extract.
The return value
is a string
containing all text
contained in those images.

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

## How well does it work?

As before we use
the edit distance
from the original text.

``` r
stringdist::stringdist(baree_hw, baree_tx)
#> [1] 446
```

Is this high?
It’s hard to know
without something
to compare against.

For example,
how does it compare
to the edit distance
between a random string
of the same length
as the target text
and the target text itself?

``` r
stringdist::stringdist(paste(sample(c(letters, " "), stringr::str_length(baree_tx), replace = TRUE), collapse = ""), baree_tx)
#> [1] 2874
```

It’s hardly surprising that this is
a much higher number.

Another comparison we could make
is against the result
of using Tesseract
to extract text
from the same handwritten pages.

Fortunately,
the
{tesseract}
(Ooms (2021))
package makes this very easy.

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
#> [1] 1502
```

So Vision API does much better than Tesseract
according to this particular little test.
But this is probably not a fair comparison.
AFAIK,
Tesseract doesn’t claim to be able to
extract text from images of handwriting.
Furthermore,
it might be possible to configure
Tesseract in a way that improves
the results
or to modify the input images
to make them better suited to Tesseract.
Also, I’m only looking at my own handwriting.
It might be that another person’s
handwriting works better with Tesseract
than mine.

My objective was just to see
if using Vision API made it possible
to convert my own handwritten documents
into text.
While it seems promising it seems
from this little experiment that I would
probably spend longer editing the resulting
texts to corrects errors than I would
spend typing them.

# Appendix (Google Cloud Platform)

A better resource
if you haven’t worked with Vision API before is:
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

You need the `glcoud` tool
to configure authentication.

The installation instructions are here:
https://cloud.google.com/sdk/docs/install

## 1. Create project

First you need to create a GCP project and enable
Vision API for that project.

You will have to setup billing when creating
the project if you haven’t done so before.

-   Go to the Project Selector:
    https://console.cloud.google.com/projectselector2/home/dashboard
    and select “Create Project”
-   Give your project a name
    and click “Create.”
-   Wait for the circly thing to spin around forever.
-   Eventually the Project Dashboard appears.
    At the time of writing
    somewhere in the bottom-left of the dashboard
    is a “Getting Started” panel
    containing a link named “Explore and enable APIs.”
    Click on it.
-   You will be transported to the API dashboard.
-   At the top you should see
    “+ ENABLE APIs AND SERVICES.”
    Click on that.
-   Now you get a search dialog.
-   Type “vision” and press enter.
-   Select “Cloud Vision API” and on the page that appears
    click the “Enable” button.

What a palaver.

## 2. Create service account

Then you need to create a service account.

This is a good point to just give up.

Strictly speaking this isn’t necessary
but it does seem to be the most straightforward way
of enable authentication for your project.

-   Click the hamburger in the navigation bar
    to open the sidebar menu.
-   Scroll down to “IAM & Admin”
    and select “Service Accounts.”
-   Click on “Create Service Account.”
-   Give your account a name.
-   Click “Create and continue”

## 3. Download private key

-   In the Service accounts dashboard find the service
    account you created and click on the three dots
    below “Action.”
-   Select “Manage Keys” from the dropdown menu.
-   On the page that open click on the “ADD KEY” button.
-   Choose “Create New Key” from the dropdown menu.
-   Click “Create” on the modal dialog that opens.
-   You will be prompted to save your key.
-   Download your private key
    and remember where you save it.
    (we refer to the save location below as `<PATH_TO_PRIVATE_KEY>`)

## 4. Use glcoud tool to get access token

Now you can use `glcoud` to get the access token
required in the above tutorial.

-   Define an environment variable
    `GOOGLE_APPLICATION_CREDENTIALS`
    pointing to the location where you saved
    the private key.

`$ export GOOGLE_APPLICATION_CREDENTIALS=<PATH_TO_PRIVATE_KEY>`

-   Then run

`$ gcloud auth application-default print-access-token`

The output will be your access token followed by lots of dots.

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-derlooStringdistPackageApproximate2014" class="csl-entry">

Loo, M.P.J. van der. 2014. “The Stringdist Package for Approximate String Matching.” *The R Journal* 6 (1): 111–22. <https://CRAN.R-project.org/package=stringdist>.

</div>

<div id="ref-oomsJsonlitePackagePractical2014" class="csl-entry">

Ooms, Jeroen. 2014. “And r Objects The Jsonlite Package: A Practical and Consistent Mapping Between JSON Data.” *arXiv:1403.2805 \[Stat.CO\]*. <https://arxiv.org/abs/1403.2805>.

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

[^1]: Disclaimer: this might just be my lack of knowledge of Tesseract
