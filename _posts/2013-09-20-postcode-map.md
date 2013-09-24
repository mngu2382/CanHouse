---
title: Mapping the suburbs in northern Caberra
layout: post
category: misc
---

_The complete code for this post is on
[GitHub](https://github.com/mngu2382/CanHouse/blob/master/90-PostcodeMap.R)._

!["Suburbs of northern Canberra"]({{ site.baseurl }}/images/postcodemap.png "Suburbs of northern Canberra")

##### R packages
- `maptools` (which requires `sp`) is used to read the shapefiles.
- `RColorBrewer` provides the colour palatte.

##### Data
- Suburb boundaries for the ACT in the form of shapefiles can be found
  [here](http://data.gov.au/dataset/canberra-suburb-boundaries). Below
  are the attributes available.
{% highlight r %}
head(div@data)
#   ID DIV_CODE   DIVISION DIVI DIST_CODE  DISTRICT DIST         AREA_SQM
# 0 33      576     SPENCE SPEN         5 BELCONNEN BELC  1521080.3835514
# 1 34      562 WEETANGERA WEET         5 BELCONNEN BELC 1592959.57680176
# 2 28      558  MACQUARIE MACQ         5 BELCONNEN BELC 1725477.62080595
# 3 21      563     HAWKER HAWK         5 BELCONNEN BELC 1946411.66888773
# 4 17      560     FLOREY FLOR         5 BELCONNEN BELC 2758198.69610702
# 5 16      574      EVATT EVAT         5 BELCONNEN BELC 3033032.07047406
{% endhighlight %}

- Postcodes are acutally the propriety of Australia Post: a list of
  postcode-location can be downloaded from Australia Post and used for
  non-commercial purposes. See
  [here](http://auspost.com.au/apps/postcode.html).
{% highlight r %}
head(pcLoc)
#   Pcode                       Locality State  Comments
# 1  0200 AUSTRALIAN NATIONAL UNIVERSITY   ACT          
# 2  0221                         BARTON   ACT       LVR
# 3  0800                         DARWIN    NT          
# 4  0801                         DARWIN    NT GPO BOXES
# 5  0803                   WAGAIT BEACH    NT  PO BOXES
# 6  0804                          PARAP    NT  PO BOXES
#                DeliveryOffice PreSortIndicator ParcelZone BSPnumber  BSPname
# 1 AUSTRALIAN NATIONAL UNI LPO              150         N2       019 CANBERRA
# 2           CANBERRA SOUTH DC              150         N2       019 CANBERRA
# 3      DARWIN DELIVERY CENTRE              085        NT1       001   DARWIN
# 4  DARWIN GPO DELIVERY ANNEXE              085        NT1       001   DARWIN
# 5            WAGAIT STORE CPA              085        NT1       001   DARWIN
# 6                   PARAP LPO              085        NT1       001   DARWIN
#            Category
# 1 Post Office Boxes
# 2               LVR
# 3     Delivery Area
# 4 Post Office Boxes
# 5 Post Office Boxes
# 6 Post Office Boxes
{% endhighlight %}

The `DIVISION` variable in the shapefile is matched to the `Locality`
variable in the Australia Post data to deduce the postcode of the
`DIVISION`.

##### TODO
Need to figure out the best way to add a scale to the map.
