---
title: Mapping the suburbs in northern Caberra
layout: post
category: misc
---

_The complete code for this post is
[here](https://github.com/mngu2382/CanHouse/blob/master/90-PostcodeMap.R)._

!["Suburbs of northern Canberra"]({{ site.url }}/images/postcodemap.png "Suburbs of northern Canberra")

##### Data
- Suburb boundaries for the ACT in the form of shapefiles can be found
  [here](http://data.gov.au/dataset/canberra-suburb-boundaries).
- Postcodes are acutally the propriety of Australia Post: a list of
  postcode-location can be downloaded from Australia Post and used for
  non-commercial purposes. See
  [here](http://auspost.com.au/apps/postcode.html).

##### R packages
- `maptools` (which requires `sp`) is used to read the shapefiles.
- `RColorBrewer` provides the colour palatte.
