---
title: "(WIP) Extract Text from Images using Google Vision API and R"
author: Matthew Henderson
slug: handwriting-to-text
date: '2020-05-03'
categories:
  - posts
tags:
  - ocr
draft: yes
editor_options: 
  chunk_output_type: console
---



Sometimes I like to take my
handwritten work,
scan it
and convert the scanned image
into text so that I can edit it on my laptop.

I can use Google Drive and Docs for this. If I upload
a scanned image to my Google Drive and open it with
Google Docs then I find the text has been extracted
and placed below the image.

Sometimes, though, I want to convert several pages into
text. Then the process of uploading lots of files,
opening each of them, cutting out the extracted
text and pasting it into a document becomes a little
inconvenient.

So I've written some code in R that will take several
scanned images, use Google Vision API to extract
the text and then paste the resulting text into a file.

## Create a GCP project and enable Vision API

First you need to create a GCP project and enable
Vision API for that project.

Then you need to create a service account
and download a private key.

You also need to download
and install Google Cloud SDK.

The steps are all described here:
https://cloud.google.com/vision/docs/setup

The final step outside R
is to generate an access token
by using the gcloud cli
with the private key
as input.

```
gcloud auth application-default print-access-token
```

The code below assumes
that there is an environment
variable
`GCLOUD_ACCESS_TOKEN`
set to the string value
returned by that call to gcloud.

## Build the request

The Vision API
can be used
by sending a http POST
request to
`https://vision.googleapis.com/v1/images:annotate`
with a JSON
payload
that looks something
like this

```json
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

This object
only has a single image
but we can
put multiple requests
into the `requests` array.

With a function
in R we can generate
a request based
on a specific image.


```r
library(base64enc)

document_text_detection <- function(image_path) {
  list(
    image = list(
      content = base64encode(image_path)
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
and uses `base64enc::base64encode`
to compute a base64 encoding
of the image.
It then packs
the resulting encoding
into a list
which can be converted
into JSON.


```r
library(httr)

request <- document_text_detection("/home/matthew/workspace/baree-scans/text/baree-1.png")

response <- POST(
     url = "https://vision.googleapis.com/v1/images:annotate",
    body = list(requests = request),
  encode = "json",
  content_type_json(),
  add_headers(
    "Authorization" = paste("Bearer", Sys.getenv("GCLOUD_ACCESS_TOKEN"))
  )
)
```



```r
content(response)$responses[[1]]$fullTextAnnotation$text
#> [1] "CHAPTER I\nT\nO Baree, for many days after he was born,\nthe world was a vast gloomy cavern.\nDuring these first days of his life his home\nwas in the heart of a great windfall where Gray Wolf,\nhis blind mother, had found a safe nest for his baby-\nhood, and to which Kazan, her mate, came only now\nand then, his eyes gleaming like strange balls of green-\nish fire in the darkness. It was Kazan's eyes that gave\nto Baree his first impression of something existing\naway from his mother's side, and they brought to him\nalso his discovery of vision. He could feel, he could\nsmell, he could hear—but in that black pit under the\nfallen timber he had never seen until the eyes came.\nAt first they frightened him; then they puzzled him,\nand his fear changed to an immense curiosity. He\nwould be looking straight at them, when all at once\nthey would disappear. This was when Kazan turned\nhis head. And then they would flash back at him again\nout of the darkness with such startling suddenness\nthat Baree would involuntarily shrink closer to his\n7\n"
```

## Multiple pages

To generate the
complete requests object
we then iterate over
all scans in the `scans_folder`
using `purrr::map`.


```r
library(purrr)

scans_folder <- "/home/matthew/workspace/baree-scans/text"

scans <- list.files(scans_folder, pattern = "*.png", full.names = TRUE)

requests <- list(
  requests = map(scans, document_text_detection)
)
```

Be careful when inspecting
this object.
The base64 encoding
of images can result
in very, very long
strings.

Another pitfall
to be wary of
is accidentally
base64encoding the path to a file
instead of the file itself.
If the response from the
Vision API has
errors that mention
those paths then that is likely to be the cause.

## Post the request and collect response

Next we use `httr:POST`
to post our request object
to the Vision API.


```r
library(httr)

response <- POST(
     url = "https://vision.googleapis.com/v1/images:annotate",
    body = requests,
  encode = "json",
  content_type_json(),
  add_headers(
    "Authorization" = paste("Bearer", Sys.getenv("GCLOUD_ACCESS_TOKEN"))
  )
)
```

There are two arguments
to `httr::POST`
that are required,
`url`
and `body`.

`url` is the page
to retrive,
in our case
`"https://vision.googleapis.com/v1/images:annotate"`

`body` is the
payload of the request.
In our case,
we have a named list
called `requests`
that needs to be
converted into JSON.
This can be done
automatically by `httr::POST`
if we also
specify the `encode = "json"` option.

To tell the server
that the content of our
request is JSON
we need to add
"Content-Type: application/json"
to the header
of our request.
We can do this
with `httr::POST`
by adding a call
to `httr::content_type_json()`
to the `...` parameters.

In the documentation
for the Vision API
we will also see
that for the request
to be accepted
it must have
a header
`Authorization = "Bearer ACCESS_TOKEN"`
where ACCESS_TOKEN
is a string
generated from our private key
by the `gcloud` tool.

## Extract text from response

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

If the status code
is 200 then you
can use the `httr::content`
to extract the content
of the response.


```r
response_content <- content(response)
```

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

Using `purrr::map` we
can extract all of those
annotations.


```r
responses_annotations <- map(response_content$responses, "fullTextAnnotation")
```

The text itself
is inside the annotations
in a object called `text`.
We can use `purrr::map_chr`
to extract those elements.


```r
responses_text <- map_chr(responses_annotations, "text")
```

Finally,
we can paste all of the pages together
and write them out to a file.


```r
library(readr)

output_text <- paste(responses_text, collapse = "\n")

write_file(output_text, file = "output.txt")
```

## How well does it work?

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
James Oliver Curwood's
"Baree, Son of Kazan.".

I scanned the pages
from the first chapter
of my copy of the novel
and downloaded the text
from Project Gutenberg as well.
Then I wrote out by
hand all of Chapter 1
and scanned the handwritten
pages.


```r
library(readr)

library(gutenbergr)

baree <- gutenberg_download(4748, mirror = "http://www.mirrorservice.org/sites/ftp.ibiblio.org/pub/docs/books/gutenberg/")

baree_ch_1_gut <- paste(baree$text[96:239], collapse = "")
baree_ch_1_ocr <- paste(responses_text, collapse = "")
```


```r
library(stringdist)

1 - stringdist(baree_ch_1_gut, baree_ch_1_ocr)/nchar(baree_ch_1_gut)
#> [1] 0.955242
```

Is that a good method to measure the distance?