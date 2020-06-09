options(stringsAsFactors = F)

library(xml2)

ns_sbml <- xml_ns_rename(xml_ns(read_xml("<root>
                                          <sbml xmlns = 'http://www.sbml.org/sbml/level3/version2/core'/>
                                          </root>")), 
                         d1 = "sbml")

ns_bioxm <- xml_ns_rename(xml_ns(read_xml("<root>
                                          <sbml xmlns = 'http://genmapp.org/GPML/2010a'/>
                                          </root>")), 
                         d1 = "bioxm")

construct_gpml <- function(path_to_gpml) {
  
  gpml <- read_xml(path_to_gpml)
  
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

lbls[toupper(lbls) == lbls] 

mnv_elements <- read.table("hackathon_covid19_map_v3-elementExport.txt", sep = "\t", header = T)
unique((unlist(strsplit(unique(mnv_elements$HGNC.Symbol), split = ",| "))))

lbls <- sapply(xml_find_all(gpml, "//bioxm:DataNode", ns = ns_bioxm), xml_attr, "TextLabel")
ids <- sapply(xml_find_all(gpml, "//bioxm:DataNode", ns = ns_bioxm), xml_attr, "GraphId")

xml_find_all(gpml, "//bioxm:DataNode", ns = ns_bioxm)
