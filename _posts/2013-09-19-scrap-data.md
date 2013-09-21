---
title: Scraping the price data
layout: post
category: misc
---

_The complete code for this post is
[here](https://github.com/mngu2382/CanHouse/blob/master/00-PriceData.R)._

Pricing data is sourced from [domain.com.au](TODO)
which has records of property sales dating back to 1990. The "Sales
History" table displays up to 20 records at a time.

Using `curl` we can get directly at the content of the table. There is
a limit to how many records you can request per post, I'm not sure how
many, I'm sticking with 20. _(Thanks goes to my housemate, MT, for
helping me figure this one out)_:

{% highlight bash %}
curl -H "Content-Type: multipart/form-data" -X POST \
       -F "locationType=Postcode" -F "state=ACT" \
       -F "postcodeId=141" -F "id=141" \
       -F "recordFrom=1" \
       -F "recordTo=20" \
       http://apm.domain.com.au/AJAX/Research/SalesHistory.aspx
{% endhighlight %}

This returns the html markup of the table of the 20 most recent
recorded sales of properties with postcode 2602 (i.e. with
`postcodeId=141`). Extracting the data from the html, we end up with
the following data frame:

{% highlight r %}
head(dat)
#                  Address NrBed NrBath PropType   Price       Date
# 1 157/50 Ellenborough St     3      2     Unit      NA 2013-06-18
# 2            5 Faunce Cr     4      2    House 1130000 2013-06-15
# 3        33 Mackennal St     3      1    House  670000 2013-06-15
# 4        60 Clianthus St     3      1    House  698000 2013-06-15
# 5             3/6 Hay St     2      2     Unit      NA 2013-06-14
# 6            18 Piper St     3      1    House      NA 2013-06-13
{% endhighlight %}

The fields are:
- street address
- number of bedrooms
- number of bathrooms
- property type
- price
- date

(There was also the agent, but I've dumped that.)
