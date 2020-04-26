# COVID-19 Disease Map text mining and modeling for drug prediction

Our work present a new pipeline to quickly produce high quality disease maps and models by combining existant knowledge and text-mining approaches.
It allows to maintain computational maps and models up-to-date to quickly test hypothesis based on the current knowledge available. 

## Getting Started

The steps used in this pipeline are summarized in the file "Hackathon workflow.png".
Results of the different tools, models and scripts are available in the corresponding folder.

#
## Contributing


## Authors

* **Marek Ostaszewski** - *Integration of text mining data with network models (contact Dieter for running new analysis with updated ZOTERO library), quality check of annotations, pull-down of drug targets from DrugBank and ChEMBL* 


* **Matti Hoch** - *CellDesigner/Minerva map curation, topological network analysis, -omics data integration and analysis, biochemical interpretation of results, software implementation of methods, Minerva plugin development* 


* **Anna Niarakis - Sara Sadat Aghamiri - Vidisha Singh** - *PD to AF module conversion and automatic Boolean model inference for Interferon, apoptosis, ER stress, Ubiquitination, PAMP signalling modules* 


* **Cristobal Monraz Gomez** - *Maps quality checkup, ER stress map to repository, add literature to ZOTERO library*


* **Inna Kuperstein** - *Collecting the repository - Remind to upload maps + pin yourself on the top level view map in the MINERVA (aske per working group) + References to annotations and to ZOTERO library*


* **Dieter Maier** - *Literature mining, tagging publications, extraction of molecular and cellular interaction triples (subject - predicate - object) including disease/symptoms and strain association. Integration with structured resources such as DisGenNet, VirHostNet*


* **Tomas Helikar with Bhanwar Lal Puniya and Robert Moore** - *Produce a logical model in Cell Collective, based on the map conversion by Anna Niarakis. The model will be publicly available, simulatable, and further expandable in Cell Collective. We can also annotate the model at the interaction level*


* **Rupert Overall** - *Text mining resource: Existing database of c. 90000 statements (directed, signed interaction network) linked to the source literature. The database is being expanded in real time as new articles/preprints appear. The data are freely accessible through a web interface allowing intuitive searches and rapid identification of novel interaction partners*


* **Charles Auffray** - *Tagging publications, identification of molecular and cellular pathways and virus-host interactions, muti-organ and multi-scale modelling*


* **Augustin Luna** - *Code for aligning text-mining results with COVID19 DiseaseMaps
Automated conversion of CellDesigner COVID19 DiseaseMaps to SBGN (https://cannin.github.io/covid19-sbgn)
Code to SBGNML to annotated edgelist/tab-delimited table (example output: https://www.dropbox.com/s/pcv7xsdiff54smd/pamp.simp.tsv.txt?dl=0) 
Code to convert text-mined results (using Indra: https://indra.readthedocs.io/en/latest/; compatible with Rupert Overallís results) to annotated edgelist/tab-delimited table (example output: https://www.dropbox.com/s/4i9a5wfm8rr8g2v/biorxiv.tsv.txt?dl=0); the example is from ~800 Biorxiv/Medrxiv articles from the CORD19 dataset* 


* **Marina Esteban - MarÌa PeÒa - JoaquÌn Dopazo** - *AF mechanistic modelling of COVID19 Maps and integration in HiPathia tool*


* **John Bachman - Benjamin Gyori - Harvard Medical School INDRA Team** - *INDRA database: https://db.indra.bio - Unified database incorporating pathway DBs (Pathway Commons, BioGrid, etc.) and text mining results from multiple readers (REACH, Sparser, RLIMS-P, TRIPS, etc.) used to process all PubMed abstracts along with full texts from Pubmed Central and Elsevier
INDRA network search: https://network.indra.bio - Signed and unsigned search for causal paths over information in the INDRA database. Can be used to identify common regulators/inhibitors of multiple targets, identify mechanistic rationales for proposed drugs, etc.
Covid-19 knowledge network on EMMAA: https://emmaa.indra.bio/dashboard/covid19/?tab=model - Knowledge network assembled from machine reading of CORD-19 article corpus plus additional Covid-19/SARS-CoV-2 relevant papers in PubMed. Network is automatically updated with new extractions as they are published, and can be queried within EMMAAA or browsed on NDex (http://www.ndexbio.org/#/network/a8c0decc-6bbb-11ea-bfdc-0ac135e8bacf).
CLARE dialog system for Slack - Natural-language based Slack bot to build mechanistic models through interactive querying of molecular mechanisms from multiple resources including the INDRA database. Can be incorporated within the hackathon Slack workspace.*

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
