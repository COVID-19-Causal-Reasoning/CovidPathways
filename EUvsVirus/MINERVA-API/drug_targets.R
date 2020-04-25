##################################################
## Script purpose:  MINERVA API call to retrieve 
##                  and to retrieve drugs targetting elements in the
##                  EUvsVirus COVID19 Disese Map
## Date: 25/04/2020
## Author: Marek Ostaszewski (marek.ostaszewski@uni.lu)
## MINERVA API version: 14.0
##################################################

options(stringsAsFactors = F,
        sep = "\t", quote = F, row.names = F, col.names = T)

### A convenience function to handle GET and POST requests to MINERVA API
library(httr)
library(jsonlite)

### Utility function using httr:GET to send queries to a given MINERVA Platform instance
ask_GET <- function(mnv_base, query) {
  resp <- httr::GET(url = paste0(mnv_base, query),
                    httr::add_headers('Content-Type' = "application/x-www-form-urlencoded"))
  if(httr::status_code(resp) == 200) {
    return(httr::content(resp, as = "text"))
  }
  return(NULL)
}

### Base URL of the COVID19 map
base_url <- "https://covid19map.lcsb.uni.lu/minerva/api/projects/hackathon_covid19_map_v2/"

### Request identifiers of models for a given project (main map and submaps)
models <- ask_GET(base_url, "models/")
models <- fromJSON(models, flatten = F)

if(!dir.exists("element_jsons")) {
  dir.create("element_jsons")
}

if(!dir.exists("overlays")) {
  dir.create("overlays")
}

if(!dir.exists("drug_targets")) {
  dir.create("drug_targets")
}

### For each model, retrieve elements with columns including references
model_elements <- lapply(models$name, 
                         function(x) {
                            id <- models[which(models$name == x),]$idObject
                            elements_JSON <- ask_GET(paste0(base_url,"models/",id,"/"),
                                                      "bioEntities/elements/?columns=id,elementId,name,type,references")
                            # Save all element annotations
                            cat(elements_JSON, file = paste0("./element_jsons/",x,"_annotations.json"))
                            fromJSON(elements_JSON, flatten = F)})

all_drugtarget_hgncs <- c()
for(m in 1:length(model_elements)) {
  message(paste0("Processing ",models$name[m]))
  tot_res <- data.frame(drug = character(0), identifier = character(0), from = character(0), target = character(0))
  hgncs <- sapply(model_elements[[m]]$references, function(x) {
    if("HGNC_SYMBOL" %in% x$type) {
      return(unlist(x[x$type == "HGNC_SYMBOL",c("resource")]))
    } else {
      return(NA)
    }
  })
  all_drugtarget_hgncs <- unique(c(all_drugtarget_hgncs,hgncs))
  valid_targets <- data.frame(alias = model_elements[[m]]$id, hgnc = hgncs)
  valid_targets <- valid_targets[!is.na(valid_targets$hgnc),]
  if(nrow(valid_targets) == 0) { next; }
  for(vt in 1:nrow(valid_targets)) {
    res <- ask_GET(base_url,paste0("drugs:search?target=ALIAS:",valid_targets[vt,1]))
    res <- fromJSON(res)
    if(length(res$name) > 0) {
      this_res <- cbind(res$name, res$references[[1]]$resource,res$references[[1]]$type,valid_targets[vt,2])
      tot_res <- rbind(tot_res, this_res)
    }
  }
  tot_res <- unique(tot_res)
  colnames(tot_res) <- c("drug", "identifier", "from", "target")
  write.table(tot_res, file = paste0("drug_targets/",models$name[m],".txt"),
              sep = "\t", quote = F, row.names = F, col.names = T)
}

tab <- cbind(identifier_hgnc_symbol = all_drugtarget_hgncs, color = "#90EE90")

write.table(tab, file = "overlays/all_MINERVA_targets.txt",
            sep = "\t", quote = F, row.names = F, col.names = T)
