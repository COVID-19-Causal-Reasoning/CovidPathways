##################################################
## Project: COVID-19 Disease Map
## Script purpose: Translate raw CellDesigner SIF to Entrez identifiers using MINERVA 
## Date: 05.06.2020
## Author: Marek Ostaszewski
##################################################

library(httr)
library(jsonlite)

### A convenience function to handle API queries
ask_GET <- function(furl, fask) {
  resp <- httr::GET(url = paste0(furl, fask),
                    httr::add_headers('Content-Type' = "application/x-www-form-urlencoded"),
                    ### Currently ignoring SSL!
                    httr::set_config(config(ssl_verifypeer = 0L)))
  if(httr::status_code(resp) == 200) {
    return(httr::content(resp, as = "text"))
  }
  return(NULL)
}

### Define the source file (GitLab, raw link)
diagram <- "https://git-r3lab.uni.lu/covid/models/-/raw/master/Curation/Apoptosis/Apoptosis_03.06.2020.xml"

### Read in the raw SIF version (here straight from the github of Aurelien)
raw_sif <- read.table(url("https://raw.githubusercontent.com/aurelien-naldi/preliminary-covid-modeling/master/covid-models/Apoptosis_03.06.2020_raw.sif"),
                      sep = " ", header = F, stringsAsFactors = F)

### Read the list of resources to be integrated, from the MINERVA build scripts
res <- read.csv(url("https://git-r3lab.uni.lu/covid/models/raw/master/Integration/MINERVA_build/resources.csv"),
                header = T, stringsAsFactors = F)

diag_name <- res[res$Resource == diagram, "Name"]

### Get MINERVA elements
### The address of the COVID-19 Disease Map in MINERVA
map <- "https://covid19map.elixir-luxembourg.org/minerva/api/"
### Get configuration of the COVID-19 Disease Map, to obtain the latest (default) version
cfg <- fromJSON(ask_GET(map, "configuration/"))
project_id <- cfg$options[cfg$options$type == "DEFAULT_MAP","value"]
### The address of the latest (default) build 
mnv_base <- paste0(map,"projects/",project_id,"/")

message(paste0("Asking for diagrams in: ", mnv_base, "models/"))

### Get diagrams
models <- ask_GET(mnv_base, "models/")
models <- fromJSON(models, flatten = F)

this_refs <- models[models$name == diag_name]

### Get elements of the chosen diagram
model_elements <- fromJSON(ask_GET(paste0(mnv_base,"models/",models$idObject[models$name == diag_name],"/"), 
                                   "bioEntities/elements/?columns=id,name,type,references,elementId,complexId,bounds"),
                           flatten = F)

message("Fetching entrez ids...")
### Get information about Entrez identifiers from MINERVA elements
entrez <- sapply(model_elements$references, function(x) ifelse(length(x) == 0, NA, x[x$type == "ENTREZ", "resource"]))
names(entrez) <- model_elements$elementId

### An utility function to retrieve Entrez based on the species id
### if the id is a complex, the function goes recursively and fetches the ids of elements in this complex
group_elements <- function(feid, felements, fentrez) {
  pos <- which(felements$elementId == feid)
  ### Any elements that may be nested in the 'feid' (CellDesigner alias)
  incs <- felements$elementId[felements$complexId %in% felements$id[pos]]
  if(length(incs) > 0) {
    ### If nested elements found, run the function recursively for the contained elements
    return(paste(unlist(sapply(incs, group_elements, felements, fentrez)), collapse = ";"))
  } else {
    ### If no nested elements, return Entrez
    rid <- fentrez[[feid]]
    if(is.na(rid)) {
      ### If Entrez not available, return name
      rid <- felements$name[pos]
    }
    return(rid)
  }
}

message("Translating...")
### Create a copy
translated_sif <- raw_sif
### Retrieve Entrez for the entire columns of sources and targets
translated_sif[,1] <- sapply(raw_sif[,1], group_elements, model_elements, entrez)
translated_sif[,3] <- sapply(raw_sif[,3], group_elements, model_elements, entrez)
### Collect x.y information
colnames(translated_sif) <- c("source", "sign", "target")
s.xy <- t(sapply(raw_sif[,1], function(x) unlist(model_elements$bounds[model_elements$elementId == x, c(3,4)])))
colnames(s.xy) <- c("source.x", "source.y")
t.xy <- t(sapply(raw_sif[,3], function(x) unlist(model_elements[model_elements$elementId == x,1][,c(3,4)])))
colnames(t.xy) <- c("targets.x", "targets.y")
### Combine into a single data frame
translated_sif <- data.frame(translated_sif, s.xy, t.xy)

write.table(translated_sif, file = "translated_sif.txt",
            sep = "\t", quote = F, col.names = F, row.names = F)
message("Done.")
