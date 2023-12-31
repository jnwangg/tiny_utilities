library(Seurat)
library(biomaRt)

#' @title IDtoSymbol
#'
#' @description Convert Ensembl gene IDs to gene symbols in-place for the given Seurat object.
#' @param object A Seurat object.
#' @param species BioMart dataset to query. Default: human (hsapiens_gene_ensembl).
#' @param release Ensembl release to query. Default: 110 (latest as of Dec. 2023).
#' @param saveConversion Saves ID-symbol conversion dataframe to global environment as an object 'conversions'. Default: TRUE
#' 
#' @return Converted Seurat object.
#'
IDtoSymbol <- function(object, species = "human", release = 110, saveConversion = FALSE) {
  # Confirm function parameters to user.
  print(paste0("Converting Seurat object using database '", species, "' and Ensembl release ", release, "."))
  print("Please double-check these are your desired parameters.")
  
  # Retrieve gene IDs from the given Seurat object and remove version numbers.
  geneIDs <- rownames(object@assays$RNA@meta.features)
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
  
  # If desired, save ID-Symbol conversion dataframe to global environment.
  if (saveConversion) assign("conversions", geneIDs, envir = .GlobalEnv)
  
  # Update @counts, @data, and @meta.features in the given Seurat object.
  assay <- object@assays$RNA
  assay@counts@Dimnames[[1]]     <- geneIDs$external_gene_name
  assay@data@Dimnames[[1]]       <- geneIDs$external_gene_name
  rownames(assay@meta.features)  <- geneIDs$external_gene_name
  object@assays$RNA <- assay
  
  return(object)
}

#' @title getSymbols
#' 
#' @description Retrieve corresponding gene symbols via BioMart.
#' @param ensembl BioMart database & dataset to query.
#' @param geneIDs List of Ensembl IDs to convert.
#' 
#' @return Dataframe of gene IDs and converted symbols.
#' 
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
