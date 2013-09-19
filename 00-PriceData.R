# Get Canberra property sales data by postcode

# PostcodeID: Postcode
# 141: 2602
# 221: 2612
# 261: 2617
# 371: 2912
# 381: 2913

GetSalesRecord <- function(PostcodeId) {

    tmpfilename <- paste("./tmp", as.character(PostcodeId), sep="")
    filename <- paste("./PostcodeId", as.character(PostcodeId), ".txt", sep="")

    if (file.exists(tmpfilename)) file.remove(tmpfilename)
    if (file.exists(filename)) file.remove(filename)
    
    recordFrom <- 1
    recordTo <- 20

    # if the file doesn't exist or if it is less than 270 lines
    while (!file.exists(tmpfilename) || {
               s <- paste("wc -l", tmpfilename)
               s <- system(s, intern=T)
               s <- as.integer(strsplit(s, split=" ")[[1]][1])
               s > 270
           }) {

        # curl command, output directed to ./tmp
        s <- paste('curl -s -H "Content-Type: multipart/form-data" -X POST \\
                   -F "locationType=Postcode" -F "state=ACT" \\
                   -F "postcodeId=', PostcodeId, '" \\
                   -F "id=', PostcodeId, '" \\
                   -F "recordFrom=', recordFrom, '" \\
                   -F "recordTo=', recordTo, '" \\
                   http://apm.domain.com.au/AJAX/Research/SalesHistory.aspx',
                   sep="")
        system(paste(s, ">", tmpfilename))
        
        # with tmpfile
        #   remove first 27 lines
        #   reverse cat
        #   remove first 11 lines
        #   reverse cat again
        #   remove leading whitespace of each line
        #   get lines starting with "<td"
        #   replace openning "<td>" tag with quote (")
        #   replace closing "</td>" tag with quote (")
        #   remove opening "<a>" tag
        #   remove closing "</a>" tag and append to ./tmp1
        system(paste("sed '1,27d'", tmpfilename, "|
                    tac |                     
                    sed '1,11d' |             
                    tac |                     
                    sed -r 's/^\\s+//g' |      
                    grep '^<td' |             
                    sed 's/^<td[^<]*>/\"/g' |   
                    sed 's/<\\/td>/\"/g' |       
                    sed 's/<a[^<]*>//g' |    
                    sed 's/<\\/a>//g' >>", filename))
    
        recordFrom <- recordFrom + 20
        recordTo <- recordTo + 20
    }
    
    file.remove(tmpfilename)

}

GetSalesRecord(141)  # 2602
GetSalesRecord(261)  # 2617
GetSalesRecord(371)  # 2912
GetSalesRecord(381)  # 2913

MakeDataFrame <- function(filename) {
    dat <- scan(filename, what="character", sep="\n")
    dat <- gsub('\\"|,|\\$|&nbsp;', "", dat)
    dat <- as.data.frame(matrix(dat, ncol=7, byrow=T),
                         stringsAsFactors=F)
    names(dat) <- c("Address","NrBed","NrBath","PropType",
                    "Agent","Price","Date")
    dat <- within(dat, {
        NrBed <- as.integer(NrBed)
        NrBath <- as.integer(NrBath)
        Price <- as.integer(Price)
        Date <- as.Date(Date, "%d/%m/%Y")
        Agent <- NULL
    })
}

Sales2602 <- MakeDataFrame("./PostcodeId141.txt")
write.table(Sales2602, "./Sales2602.csv", sep=",", row.names=F)
Sales2617 <- MakeDataFrame("./PostcodeId261.txt")
write.table(Sales2617, "./Sales2617.csv", sep=",", row.names=F)
Sales2912 <- MakeDataFrame("./PostcodeId371.txt")
write.table(Sales2912, "./Sales2912.csv", sep=",", row.names=F)
Sales2913 <- MakeDataFrame("./PostcodeId381.txt")
write.table(Sales2913, "./Sales2913.csv", sep=",", row.names=F)
