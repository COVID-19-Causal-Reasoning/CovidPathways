##################################################
## Project: COVID-19 Disease Map
## Script purpose: Access identifiers of elements in MINERVA 
## Date: 01.04.2020
## Author: Marek Ostaszewski
##################################################

options(stringsAsFactors = F)

library(httr)
library(jsonlite)
library(here)

setwd(paste0(here(),"/Integration/MINERVA_build/"))

### Map and pathway enrichment analysis.
### Requires commandline input or file "input.txt" to be present in the script directory.

### A convenience function to handle API queries
ask_GET <- function(furl, fask) {
  resp <- httr::GET(url = paste0(furl, fask),
                    httr::add_headers('Content-Type' = "application/x-www-form-urlencoded"))
  if(httr::status_code(resp) == 200) {
    return(httr::content(resp, as = "text"))
  }
  return(NULL)
}

### The address of the COVID-19 Disease Map in MINERVA
map <- "https://covid19map.elixir-luxembourg.org/minerva/api/"

### Get configuration of the COVID-19 Disease Map, to obtain the latest (default) version
cfg <- ask_GET(map, "configuration/")
cfg <- fromJSON(cfg)
project_id <- cfg$options[cfg$options$type == "DEFAULT_MAP","value"]

### The address of the latest (default) build 
mnv_base <- paste0(map,"projects/",project_id,"/")

message(paste0("Asking for diagrams in: ", mnv_base, "models/"))

### Get diagrams
models <- ask_GET(mnv_base, "models/")
models <- fromJSON(models, flatten = F)

### Get elements of diagrams
model_elements <- lapply(models$idObject, 
                         function(x) fromJSON(ask_GET(paste0(mnv_base,"models/",x,"/"), 
                                                      "bioEntities/elements/?columns=id,name,type,references"), 
                                              flatten = F))

all_hgncs <- c()
### Go through all diagram elements and:
for(me in model_elements) {
  ### For erroneous response, skip to next diagram
  if(is.null(me)) { next }
  ### Only elements that have annotations
  these_refs <- me$references[sapply(me$references, length) > 0]
  ### For empty list, skip to next diagram
  if(length(these_refs) == 0) { next }
  
  ### Get all HGNC symbols, for elements that have annotations
  all_hgncs <- c(all_hgncs, sapply(these_refs,
                                   function(x) x[x$type == "HGNC_SYMBOL", "resource"]))
  all_hgncs <- all_hgncs[sapply(all_hgncs,
                                function(x) ifelse(is.character(x) & length(x) > 0, TRUE, FALSE))]
}

### Get unique HGNC symbols
all_hgncs <- unique(all_hgncs)


