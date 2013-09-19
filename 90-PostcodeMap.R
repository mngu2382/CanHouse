library(maptools)
library(RColorBrewer)

palHex <- c(brewer.pal(4, "Pastel1"), "#FFFFFF")
postcode <- c("2602","2617","2912","2913")

pcLoc <- read.table("test/pc-full_20130826.csv", sep=",",
                       header=T, colClasses="character")
pcLoc <- subset(pcLoc, State=="ACT")
pcLoc <- within(pcLoc, colCode <- match(Pcode, postcode, nomatch=5))

div <- readShapePoly("ACT_DIVI.shp")
div1 <- subset(div,
               DIVISION %in% subset(pcLoc, colCode < 5)$Locality |
               DIVISION=="CITY")
div2 <- subset(div,
               findInterval(coordinates(div)[,1], bbox(div1)[1,]) == 1 &
               findInterval(coordinates(div)[,2], bbox(div1)[2,]) == 1)
div2 <- div2[match(unique(div2$DIVISION), div2$DIVISION),]

pltCol <- sapply(div2a$DIVISION,
                 function(s) min(subset(pcLoc, Locality==s)$colCode))

par(mar=c(0, 0, 3, 0))
plot(div2, border="#444444", col=palHex[pltCol])
title("Suburbs of Northern Canberra", font.main=1)
text(coordinates(div2), labels=div2$DIVISION, cex=0.6)
legend("bottomright", legend=postcode, fill=palHex[1:4],
       bty="n", inset=0.03, title="Postcode", cex=0.9)

