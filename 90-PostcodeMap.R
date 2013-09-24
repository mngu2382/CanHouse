library(maptools)
library(RColorBrewer)

pal <- c(brewer.pal(4, "Pastel1"), "#FFFFFF")
postcode <- c("2602","2617","2912","2913")

pcLoc <- read.table("data/pc-full_20130826.csv", sep=",",
                       header=T, colClasses="character")
pcLoc <- subset(pcLoc, State=="ACT")
pcLoc <- within(pcLoc, colCode <- match(Pcode, postcode, nomatch=5))

div <- readShapePoly("data/ACT_DIVI.shp")

# Gets suburbs matching postcodes in `postcode`
div1 <- subset(div,
               DIVISION %in% subset(pcLoc, colCode < 5)$Locality |
               DIVISION=="CITY")
# Gets other suburbs in the surrounding area as well
div2 <- subset(div,
               findInterval(coordinates(div)[,1], bbox(div1)[1,]) == 1 &
               findInterval(coordinates(div)[,2], bbox(div1)[2,]) == 1)
# Leaves out duplicated divisions
div2 <- div2[match(unique(div2$DIVISION), div2$DIVISION),]

pltCol <- sapply(div2$DIVISION,
                 function(s) min(subset(pcLoc, Locality==s)$colCode))

png("figures/postcodemap.png", height=900, width=630, res=96)
par(mar=c(0, 0, 3, 0))
plot(div2, col=pal[pltCol], lwd=0.2)
title("Suburbs of Northern Canberra", font.main=1, col.main="#dd3322")
text(coordinates(div2), labels=div2$DIVISION, cex=0.6)
legend("bottomright", legend=postcode, fill=pal[1:4],
       bty="n", inset=0.03, title="Postcode", cex=0.8)
dev.off()
