# Using Google geocoding API to get suburb and location

library(rjson)

dat <- read.table("./data/Sales2602.csv", sep=",", header=T,
                  colClasses=c("character","integer","integer",
                               "factor","integer","Date"))

# filtering data
dat <- subset(dat,
              Date >= "1990-01-01" & Date < "2013-07-01" &
              PropType %in% c("House", "Unit") &
              !is.na(Price))

dat <- within(dat, {
    Address <- paste(as.character(Address), "ACT 2602 AUSTRALIA")
})

GetGoogleMapJSON <- function(address) {
    URL <- paste("http://maps.googleapis.com/maps/api/geocode/",
                 "json?address=", gsub(" ","\\+", address),
                 "&sensor=false", sep="")
    tryCatch(fromJSON(paste(readLines(URL), collapse="")),
             error=function(e) e)
}

# Google geocodding API limit of 2500 a day 
GoogleMapJSON <- lapply(dat$Address[1:2250], GetGoogleMapJSON)
# save.image("tmp.Rda")
# library(rjson)
# load("tmp.Rda")
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[2251:4500]), GetGoogleMapJSON)
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[4501:6750]), GetGoogleMapJSON)
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[6751:9000]), GetGoogleMapJSON)
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[9001:11250]), GetGoogleMapJSON)
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[11251:13500]), GetGoogleMapJSON)
GoogleMapJSON <-
    c(GoogleMapJSON, lapply(dat$Address[13501:nrow(dat)]), GetGoogleMapJSON)

# resubmit any address did not return a result the first time
for (i in 1:length(GoogleMapJSON))
    if (inherits(GoogleMapJSON[[i]], "error") |
        GoogleMapJSON[[i]][[2]] != "OK")
        GoogleMapJSON[[i]] <-GetGoogleMapJSON(names(GoogleMapJSON)[i])

# save.image("tmp.Rda")
# load("tmp.Rda")

# check status
# table(sapply(GoogleMapJSON, function(x) x[[2]])) 

# extract address, suburb, latitude and longitude
addressGoogle <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$formatted_address,
                         error=function(e) NA))
suburb <- sapply(strsplit(addressGoogle, split=","),
    function(x) {
        if (length(x) == 3) {
            gsub("^\\s+|\\s+$", "", x[2])
        } else {
            gsub("^\\s+|\\s+$", "", x[1])
         }})
suburb <- sub(" ACT 2602", "", suburb)
lat <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lat,
                         error=function(e) NA))
lng <- sapply(GoogleMapJSON,
    function(x) tryCatch(x[[1]][[1]]$geometry$location$lng,
                         error=function(e) NA))

dat_Google <- data.frame(addressGoogle, suburb, lat, lng)

dat <- cbind(dat, dat_Google)

write.table(dat, "Sales2602_wcoord.csv",
            sep=",", quote=T, row.names=F)
