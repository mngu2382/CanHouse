---
title: Using Google's Geocoding API
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

The two required parameters is (1) a location value such as an `address`
and (2) a `sensor` value, `true` or `false`, indicating whether or not
the geocoding request come from a device with a location sensor.

For example, for the address `West 35th, New York`, we could send the
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
example, to extrac the latitude and longitude
{% highlight r %}
lat <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lat,
                         error=function(e) NA))
lng <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lng,
                         error=function(e) NA))
{% endhighlight %}

