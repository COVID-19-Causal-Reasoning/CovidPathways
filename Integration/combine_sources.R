##################################################
## Project: COVID-19 Disease Map
## Script purpose: Combine maps from different sources 
## Date: 01.04.2020
## Author: Marek Ostaszewski
##################################################

library(httr)

### Read the list of resources to be integrated
res <- read.csv(url("https://git-r3lab.uni.lu/covid/models/raw/master/Integration/resources.csv"),
                header = T, stringsAsFactors = F)

gpmls <- res[res$Type == "GPML",]

for(r in 1:nrow(gpmls)) {
  con <- url(gpmls[r,]$Resource)
  rls <- paste(readLines(con), collapse = "\n")
  close(con)
  
  ### We use httr::POST to execute the API call, and then write down the response
  res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/GPML:CellDesigner_SBML",
                    body = rls,
                    content_type("text/plain"))
  ### Get resulting XML content as text
  cont <- content(res, as = "text")
  ### Get resource filename to name the output, last token after splitting by '/'
  fname <- tail(unlist(strsplit(gpmls[r,]$Resource, split = "/")),1)
  ### Write the result to a file
  cat(cont, file = paste0(fname,".xml"))
}


