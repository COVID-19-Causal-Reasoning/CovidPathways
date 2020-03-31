##################################################
## Project: COVID-19 Disease Map
## Script purpose: Convert WikiPathways (GPML) using MINERVA API calls (v15.beta.2)
##                 see documentation at https://minerva.pages.uni.lu/doc/api/
##                 Warning: v15.beta.2 is still being tested, GPML not among handled formats in the documentation
## Date: 31.03.2020
## Author: Marek Ostaszewski
##################################################

library(httr)

### An example file will be a WikiPathways file set up 
### by Egon Wilighagen at https://github.com/wikipathways/SARS-CoV-2-WikiPathways
infile <- "https://raw.githubusercontent.com/wikipathways/SARS-CoV-2-WikiPathways/master/gpml/WP4846.gpml"

### Create a character vector of the xml file, read line by line, close connection
con <- url(infile)
rls <- paste(readLines(con), collapse = "\n")
close(con)

### Scenario A
### Convert the WikiPathways GPML file to a CellDesigner file
### an example curl call for this would be:
### curl -X POST --data-binary @infile -H 'Content-Type: text/plain' https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/GPML:CellDesigner_SBML > outfile

### We use httr::POST to execute the API call, and then write down the response
res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/GPML:CellDesigner_SBML",
                  body = rls,
                  content_type("text/plain"))
### Get resulting XML content as text
cont <- content(res, as = "text")
### Write the result to a file
cat(cont, file = "out.xml")

### Scenario B
### Convert the WikiPathways GPML file to a PNG preview, useful for a quick check if conversion was acceptable 
### an example curl call for this would be:
### curl -X POST --data-binary @infile -H 'Content-Type: text/plain' https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/image/GPML:png > outfile

### Similarly, we use httr::POST to execute the API call, and then write down the response
res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/image/GPML:png",
                  body = rls,
                  content_type("text/plain"))
### Here, the content is binary (PNG image)
cont <- content(res, as = "raw", type = "image/png")
### We use the "write binary" routine of R (open connection, writeBin, close connection)
write.filename = file("out.png", "wb")
writeBin(cont, write.filename)
close(write.filename)
