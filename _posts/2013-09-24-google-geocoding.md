---
title: Using Google's Static Maps and Geocoding API
layout: post
category: misc
---

_The complete code for this post is on
[GitHub](https://github.com/mngu2382/CanHouse/blob/master/91-Geocoding.R)._

##### R package
- [`rjson`](http://cran.r-project.org/web/packages/rjson/index.html)
  is used to parse the geocoding output.

##### Geocoding Requests
Using Google's Geocoding API is very simple. From the
[documentation](https://developers.googe.com/maps/documentation/geocoding/#GeocodingRequests)
requests should be of the following form:

    http://maps.googleapis.com/maps/api/geocoding/[output]?[parameters]

where output is the output format (either `json` or `xml`) and
parameters include required and optional values separated by an
ampersand (`&`).

The two required parameters:

1. a location value such as an `address`

2. a `sensor` value, `true` or `false`, indicating whether or not the
   geocoding request come from a device with a location sensor


For example, for the address "West 35th, New York", we could send the
following request:

    http://maps.googleapis.com/maps/api/geocoding/json?address=west+35th+new+york&sensor=false

So, wraping the request in an R function, for a list/vector of
addresses, we can retrive the geocoding data
{% highlight r %}
GetGoogleMapJSON <- function(address) {
    URL <- paste("http://maps.googleapis.com/maps/api/geocode/",
                 "json?address=", gsub(" ","\\+", address),
                 "&sensor=false", sep="")
    tryCatch(fromJSON(paste(readLines(URL), collapse="")),
             error=function(e) e)
}

GoogleMAPJSON <- lapply(addresses, GetGoogleMapJSON)
{% endhighlight %}

Note that there is a limit on the API of 2500 request per day, more
than that and the `results` field in the JSON output is empty and the
`status` field contains an `"OVER_QUERY_LIMIT"` value.

Because of this limit, there is an exception handling step in
`GetGoogleMapJSON` so that in the case of something like a connection
error, we don't lose previous successful requests.

Now that we have a list of geocoding data for each address extracting
desired attributes is simple a matter of using `sapply`/`lapply`, for
example, to extract the latitude and longitude
{% highlight r %}
lat <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lat,
                         error=function(e) NA))
lng <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lng,
                         error=function(e) NA))
{% endhighlight %}

So we now, consolidating the data into a data frame:
{% highlight r %}
head(dat)
#                                        Address NrBed NrBath PropType   Price
# 1               5 Faunce Cr ACT 2602 AUSTRALIA     4      2    House 1130000
# 2           33 Mackennal St ACT 2602 AUSTRALIA     3      1    House  670000
# 3           60 Clianthus St ACT 2602 AUSTRALIA     3      1    House  698000
# 4             40 Raymond St ACT 2602 AUSTRALIA     3      1    House  730000
# 5 22/21 Cossington Smith Cr ACT 2602 AUSTRALIA     3      1     Unit  420000
# 6              36  Negus Cr ACT 2602 AUSTRALIA     4      2    House  770000
#         Date status
# 1 2013-06-15     OK
# 2 2013-06-15     OK
# 3 2013-06-15     OK
# 4 2013-06-13     OK
# 5 2013-06-11     OK
# 6 2013-06-08     OK
#                                                  addressGoogle   suburb
# 1              5 Faunce Crescent, O'Connor ACT 2602, Australia O'Connor
# 2             33 Mackennal Street, Lyneham ACT 2602, Australia  Lyneham
# 3            60 Clianthus Street, O'Connor ACT 2602, Australia O'Connor
# 4               40 Raymond Street, Ainslie ACT 2602, Australia  Ainslie
# 5 22/21 Cossington Smith Crescent, Lyneham ACT 2602, Australia  Lyneham
# 6                36 Negus Crescent, Watson ACT 2602, Australia   Watson
#          lat        lng
# 1 -35.266748 149.116408
# 2 -35.247003 149.122385
# 3 -35.251226 149.115978
# 4 -35.255091 149.154808
# 5 -35.241862 149.125098
# 6 -35.233724 149.161682
{% endhighlight %}

!["Residental properties sold since 1991 in inner northern suburbs of Canberra"]({{ site.baseurl }}/images/92-GeocodingMap.png "Residental properties sold since 1991 in inner northern suburbs of Canberra")

_R code for this map on
[GitHub](https://github.com/mngu2382/CanHouse/blob/master/92-GeocodingMap.R)._
