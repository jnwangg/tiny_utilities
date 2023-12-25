library(Seurat)
library(biomaRt)

# Convert Ensembl gene IDs to gene symbols in-place for the given Seurat object.
IdtoSymbol <- function(seurObj, species = "human") {
  # Retrieve gene IDs from the given Seurat object.
  geneIDs <- rownames(seurObj@assays[["RNA"]]@meta.features)
  
  # Select the appropriate BioMart dataset.
  ensembl <- useEnsembl(biomart = "genes")
  if (species == "human") {
    ensembl <- useDataset(dataset = "hsapiens_gene_ensembl", mart = ensembl)
  }
  else if (species == "mouse") {
    ensembl <- useDataset(dataset = "mmusculus_gene_ensembl", mart = ensembl)
  }
  else if (species == "macaque") {
    ensembl <- useDataset(dataset = "mfascicularis_gene_ensembl", mart = ensembl)
  }
  else {
    ensembl <- useDataset(dataset = species, mart = ensembl)
  }
  
  # Retrieve corresponding gene symbols.
  geneIDs <- getSymbols(ensembl, geneIDs)
}

# Retrieve corresponding gene symbols via BioMart.
getSymbols <- function(ensembl, geneIDs) {
  geneIDs <- getBM(attributes = c('ensembl_gene_id_version', 'external_gene_name'),
                   filters = 'ensembl_gene_id_version',
                   values = geneIDs,
                   mart = ensembl)
  return(geneIDs)
}
