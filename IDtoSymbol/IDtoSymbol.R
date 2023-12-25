library(Seurat)
library(biomaRt)

# Takes a Seurat object and converts Ensembl gene IDs to gene symbols in-place.
IdtoSymbol <- function(seurObj) {
  # Retrieve gene IDs from the given Seurat object and removes version numbers.
  geneIDs <- rownames(seurObj@assays[["RNA"]]@meta.features)
  geneIDs <- gsub("\\.\\d+$", "", geneIDs)
  
  
  
}