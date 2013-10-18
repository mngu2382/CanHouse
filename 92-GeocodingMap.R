## Plotting house coordinates of map
library(ggplot2)
library(plyr)
library(grid)
library(png)

deg2rad <- function(degrees)
    degrees * pi / 180
lng2x <- function(lng)
    128 * (1 + deg2rad(lng) / pi)
lat2y <- function(lat) {
    sinphi <- sin(deg2rad(lat))
    128 * ( 1 - log((1 + sinphi) / (1 - sinphi)) / (2 * pi))
}
world2pixel <- function(x, zoomLevel=13, scale=T) {
  scale_factor <- ifelse(scale, 1, 0)
  x * 2 ^ (zoomLevel + scale_factor)
}
zoomLevel = 13

dat <- read.table("./data/Sales2602_wcoord.csv", sep=",",
                  header=T, colClasses="character")
dat <- within(dat, {
    Date <- as.Date(Date)
    lat <- as.numeric(lat)
    lng <- as.numeric(lng)

    # Calculate pixel coordinates; using zoomLevel + 1 since scale
    # parameter was 2 in Google Map request, doubling the number of
    # pixels in the world at a given zoomLevel
    pixel_x <- world2pixel(lng2x(lng))
    pixel_y <- world2pixel(lat2y(lat))
})
suburbs <- ddply(dat, .(suburb), summarise,
                 pixel_y=median(pixel_y),
                 pixel_x=median(pixel_x))
suburbs <- suburbs[!suburbs$suburb=="Canberra",]

# Retreive map from Google Maps
latCentre = mean(range(dat$lat))
lngCentre = mean(range(dat$lng))
url <- paste("http://maps.googleapis.com/maps/api/staticmap?",
             "center=", latCentre, ",", lngCentre,
             "&zoom=", zoomLevel,
             "&size=640x640&scale=2&maptype=satellite&sensor=false",
             sep="")
download.file(url, "./data/map.png", mode="wb")

map <- readPNG("./data/map.png")
# Adding transparency
map_t <- array(0, c(dim(map)[1:2], 4))
map_t[,, 1:3] <- map
map_t[,, 4] <- 0.4

x_range <- range(dat$pixel_x) + c(-50, 50) -
    world2pixel(lng2x(lngCentre)) + 640
x_range <- c(floor(x_range[1]), ceiling(x_range[2]))
y_range <- range(dat$pixel_y) + c(-50, 50) -
    world2pixel(lat2y(latCentre)) + 640
y_range <- c(floor(y_range[1]), ceiling(y_range[2]))

map_test <- map_t[do.call("seq", as.list(c(y_range, 1))),
                  do.call("seq", as.list(c(x_range, 1))),]
map_test <- rasterGrob(map_test)

# from https://github.com/hadley/ggplot2/wiki/Themes
theme_fullframe <- function (base_size = 12){
  theme(
    axis.line = element_blank(), 
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    axis.ticks.length = unit(0, "lines"), 
    axis.ticks.margin = unit(0, "lines"), 
    legend.position = "none", 
    panel.background = element_blank(), 
    panel.border = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.margin = unit(0, "lines"), 
    plot.background = element_blank(), 
    plot.margin = unit(c(0, 0, 0, 0), "lines")
  )
}

ggplot(dat, aes(pixel_x, -pixel_y)) +
    geom_point(aes(colour=suburb), alpha=0.25, size=1.3) +
    geom_text(data=suburbs, aes(colour=suburb, label=suburb), size=7) +  
    annotation_custom(map_test) +
    guides(colour=guide_legend(override.aes=list(alpha=1))) +
    theme_fullframe()
ggsave("./figures/92-GeocodingMap.png", dpi=96)

## TODO:
##   - find fix, so don't have to manually adjust map size;
##     maybe by figuring out how to properly set the limits on
##     ggplot2::annotation_custom
##   - slight mismatch in map and coordinates, especially noticable
##     in top-right corner; (lat, lng) -> pixel?
