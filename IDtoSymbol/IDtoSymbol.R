library(Seurat)
library(biomaRt)

# Convert Ensembl gene IDs to gene symbols in-place for the given Seurat object.
IdtoSymbol <- function(seurObj, species = "human", release = 110) {
  # Confirm function parameters to user.
  print(paste0("Converting Seurat object using database '", species, "' and Ensembl release ", release, "."))
  print("Please double-check these are your desired parameters.")
  
  # Retrieve gene IDs from the given Seurat object and remove version numbers.
  geneIDs <- rownames(seurObj@assays$RNA@meta.features)
  geneIDs <- gsub("\\.\\d+$", "", geneIDs)
  
  # Select the appropriate BioMart dataset.
  ensembl <- useEnsembl(biomart = "genes", version = release)
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
  
  # Retrieve corresponding gene symbols. Make any duplicate symbols unique.
  geneIDs <- getSymbols(ensembl, geneIDs)
  geneIDs$external_gene_name <- make.unique(geneIDs$external_gene_name)
  
  # Replace any underscores with dashes, which are not allowed in Seurat feature names.
  geneIDs$external_gene_name <- gsub(pattern = "_", replacement = "-", 
                                     geneIDs$external_gene_name)
  
  # Update @counts, @data, and @meta.features in the given Seurat object.
  assay <- seurObj@assays$RNA
  assay@counts@Dimnames[[1]]     <- geneIDs$external_gene_name
  assay@data@Dimnames[[1]]       <- geneIDs$external_gene_name
  rownames(assay@meta.features)  <- geneIDs$external_gene_name
  seurObj@assays$RNA <- assay
  
  return(seurObj)
}

# Retrieve corresponding gene symbols via BioMart.
getSymbols <- function(ensembl, geneIDs) {
  geneIDs <- getBM(attributes = c('ensembl_gene_id', 'external_gene_name'),
                   filters = 'ensembl_gene_id',
                   values = geneIDs,
                   mart = ensembl)
  
  # If a gene symbol is unavailable, use the gene ID instead.
  for (i in 1:nrow(geneIDs)) {
    if (geneIDs$external_gene_name[i] == "") {
      geneIDs$external_gene_name[i] = geneIDs$ensembl_gene_id[i]
    }
  }
  
  return(geneIDs)
}
