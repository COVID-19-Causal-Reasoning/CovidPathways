##################################################
## Project: COVID-19 Disease Map
## Script purpose: Combine maps from different sources 
## Date: 01.04.2020
## Author: Marek Ostaszewski
##################################################

options(stringsAsFactors = F)

library(httr)
library(xml2)

### An 'xml2' namespace structure for parsing CellDesigner xml 
ns_cd <- xml_ns_rename(xml_ns(read_xml("<root>
                                       <sbml xmlns = \"http://www.sbml.org/sbml/level2/version4\"/>
                                       <cd xmlns = \"http://www.sbml.org/2001/ns/celldesigner\"/>
                                       <html xmlns = \"http://www.w3.org/1999/xhtml\"/>
                                       <rdf xmlns = \"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"/>
                                       </root>")), 
                       d1 = "sbml", d2 = "cd", d3 = "html", d4 = "rdf")

ns_sbml <- xml_ns_rename(xml_ns(read_xml("<root>
                                          <sbml xmlns = 'http://www.sbml.org/sbml/level3/version2/core'/>
                                          </root>")), 
                          d1 = "sbml")

### Ironing out of issues in files converted from GPML to CellDesigner_SBML
process_gpml <- function(source) {
  message("API translation request")
  ### We use httr::POST to execute the API call, and then write down the response
  res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/GPML:CellDesigner_SBML",
                    body = source,
                    content_type("text/plain"))
  ### Get resulting XML content as text
  cont <- content(res, as = "text")
  message("Finalizing...")
  ### Apply final corrections using the dedicated 'finalize_gpml' (output: xml)
  gpml_xml <- read_xml(cont)
  notes <- xml_find_first(gpml_xml, "//sbml:model/sbml:notes/html:html/html:body", ns_cd)
  nlines <- unlist(strsplit(xml_text(notes), "\n"))
  nlines <- nlines[-grep("CellDesigner requires (inner|outer)Width|thickness", nlines)]
  xml_text(notes) <- paste(nlines, collapse = "\n")
  return(gpml_xml)
}

### Ironing out of issues in files converted from SBGN to CellDesigner_SBML
process_sbgn <- function(source) {
  message("API translation request")
  ### We use httr::POST to execute the API call, and then write down the response
  res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/SBGN-ML:CellDesigner_SBML",
                    body = source,
                    content_type("text/plain"))
  ### Get resulting XML content as text
  cont <- content(res, as = "text")
  return(read_xml(cont))
}

process_cdsbml <- function(source) {
  cdsbml_xml <- read_xml(source)
  ### Remove all kineticLaw tags, a temporary solution for a current bug in v15.beta.2
  ### This will change
  xml_remove(xml_find_all(cdsbml_xml, "//sbml:kineticLaw", ns_cd))
  return(cdsbml_xml)
}

construct_overview <- function(elements) {
  ### Read in an SBML template 
  root <- read_xml("<?xml version='1.0' encoding='UTF-8' standalone='no'?>
                    <sbml xmlns='http://www.sbml.org/sbml/level3/version2/core' level='3' version='2'>
                      <model id='ovw' name='overview'>
                        <listOfCompartments>
                          <compartment constant='false' id='default' size='1' spatialDimensions='3' />
                        </listOfCompartments>
                        <listOfSpecies>
                        </listOfSpecies>
                      </model>
                    </sbml>")
  los <- xml_find_first(root, "//sbml:listOfSpecies", ns_sbml)
  for(e in 1:length(elements)) {
    element <- paste0("<species boundaryCondition='false' initialAmount='0' constant='false' hasOnlySubstanceUnits='false' ",
                      "compartment='default' id='nel_", e, "' name='", elements[e], "' sboTerm='SBO:0000358' />")
    xml_add_child(los, read_xml(element))
  }
  res <- httr::POST(url = "https://minerva-covid19-curation.lcsb.uni.lu/minerva/api/convert/SBML:CellDesigner_SBML",
                    body = as.character(root),
                    content_type("text/plain"))
  return(content(res, as = "text"))
}

### Read the list of resources to be integrated
### The file has the following columns:
### Include: if the resource is to be added to this build 
### Resource: url to the xml content of the diagram
### Type: what kind of file do we integrate
### Name: under which name the diaram is to be shown in the build

regular_build = T

if(regular_build) {
  ### Regular build
  res <- read.csv(url("https://git-r3lab.uni.lu/covid/models/raw/master/Integration/MINERVA_build/resources.csv"),
                  header = T, stringsAsFactors = F)
} else {
  ### WikiPathways testbuild
  wps <- readLines("https://raw.githubusercontent.com/wikipathways/SARS-CoV-2-WikiPathways/master/pathways.txt")
  res <- data.frame(Include = "Yes", 
                    Resource = paste0("https://raw.githubusercontent.com/wikipathways/SARS-CoV-2-WikiPathways/master/gpml/", wps, ".gpml"),
                    Type = "GPML",
                    Name = wps)
}

### Filter only these to be included
res <- res[res$Include == "Yes",]

### Define the output dir
outdir <- "_notgit/output/"
### Just to simplify later writes
outdir_submaps <- paste0(outdir,"submaps/")

### Create output directory if not existing.
if(!dir.exists(outdir)) { dir.create(outdir) }

### Create submaps directory if not existing.
if(!dir.exists(outdir_submaps)) { dir.create(outdir_submaps) }

### For all resources
for(r in 1:nrow(res)) {
  ### Process the 'resources' table, all should be network-accessible (raw git)
  message(paste0("Processing: ", res[r,]$Resource))
  con <- url(res[r,]$Resource)
  conread <-try(readLines(con), silent = T)
  ### Try retrieving a resource, end gracefully
  if(class(conread) == "try-error") {
    message(paste0("Cannot read from ", res[r,]$Resource))
    close(con)
    message(conread)
    next
  }
  rls <- paste(conread, collapse = "\n")
  close(con)
  fin_cont <- NULL
  ### Depending on the type, process differently
  ### see wrapper functions for MINERVA conversion API above
  if(res[r,]$Type == "GPML") {
    fin_cont <- process_gpml(rls)
  } else if (res[r,]$Type == "SBGN") {
    fin_cont <- process_sbgn(rls)
  } else if (res[r,]$Type == "CellDesigner_SBML") {
    fin_cont <- process_cdsbml(rls)
  }else {
    warning(paste0("Resource type not handled: ", res[r,]$Type))
  }

  ### Write the result to a file
  write_xml(fin_cont, file = paste0(outdir_submaps,res[r,]$Name,".xml"))
  message("Done.\n\n")
}

### If the overview map and the mapping are to be constructed de novo
reconstruct_overview = T
reconstruct_mapping = T 

if(reconstruct_overview) {
  ### Create a sinple SBML file and convert it to CellDesigner, gives circular layout
  ovw <- construct_overview(res$Name)
  
  ovw <- gsub("w=\"90.0\" h=\"30.0\"", "w=\"190.0\" h=\"40.0\"", ovw)
  ovw <- gsub("width=\"90.0\" height=\"30.0\"", "width=\"190.0\" height=\"40.0\"", ovw)
  ovw <- gsub("width=\"90.0\" height=\"30.0\"", "width=\"190.0\" height=\"40.0\"", ovw)
  ovw <- gsub("color=\"FFCC99FF\"", "color=\"FFCCFFFF\"", ovw)
  
  cat(ovw, file = paste0(outdir,"overview.xml"))
}

if(reconstruct_mapping) {
  ### Use a mapping template; mapping file requires handling complexes, which are tricky
  ### It is easier to use a preconstructed template, change names of species inside
  ### and remove unnecessary reactions
  
  ### Load the template, readlines
  con <- url("https://git-r3lab.uni.lu/covid/models/-/raw/master/Integration/MINERVA_build/template_mapping.xml")
  mapping <- paste(readLines(con), collapse = "\n")
  close(con)
  
  ### Replace the names
  for(n in 1:nrow(res)) {
    mapping <- gsub(paste0(">placeholder", n,"<"), paste0(">nel_",n,"<"), mapping)
    mapping <- gsub(paste0("\"placeholder", n,"\""), paste0("\"nel_",n,"\""), mapping)
    mapping <- gsub(paste0(">target", n,"<"), paste0(">",res[n,]$Name,"<"), mapping)
    mapping <- gsub(paste0("\"target", n,"\""), paste0("\"",res[n,]$Name,"\""), mapping)
  }
  
  ### Write to file, read in as an xml structure
  cat(mapping, file = paste0(outdir_submaps, "mapping.xml"), sep = "\n")
  mapn <- read_xml(paste0(outdir_submaps, "mapping.xml"))
  
  ### Remove all reactions whose baseReactant species is a placeholder
  for(sp in xml_find_all(mapn, "//cd:species", ns_cd)) {
    spattrs <- xml_attrs(sp)
    if(startsWith(spattrs["name"], "placeholder")) {
      br <- xml_find_first(mapn, paste0("//cd:baseReactant[@species='", spattrs["id"], "']"), ns_cd)
      xml_remove(xml_parent(xml_parent(xml_parent(xml_parent(br)))))
    }
  }
  
  ### Write down the trimmed file
  write_xml(mapn, paste0(outdir_submaps, "mapping.xml"))
}
