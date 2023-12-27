# IDtoSymbol
> A utility that converts the feature names of a Seurat object from Ensembl IDs to gene symbols, in-place. Designed to work in **Seurat v4.4**.
  
## 🔧 Usage 
> [!NOTE]
> `IDtoSymbol` is intended for use on simple Seurat objects with only an RNA assay. Changes are made to @counts, @data, and @meta.features. Please re-run any downstream analyses following conversion!

`IDtoSymbol` must be run with a Seurat object, but has additional functionality for more specific tasks.
```
Usage: IDtoSymbol(
         object,
         species = "human",
         release = 110,
         saveConversion = TRUE
)
```
  
## ⚙️ Arguments
> [!TIP]
> Gene symbols often associate to multiple Ensembl IDs. `IDtoSymbol` makes symbols unique by appending numbers to duplicates, e.g. 7SK, 7SK.1, 7SK.2. Use `saveConversion = TRUE` to save the generated ID-symbol conversion dataframe if you need to differentiate between these duplicates in your downstream analysis.

`object`: A Seurat object.

`species`: BioMart dataset to query. Three shortcut parameters are available, for convenience:

```
human    | Selects hsapiens_gene_ensembl. Default.
mouse    | Selects mmusculus_gene_ensembl.
macaque  | Selects mfascicularis_gene_ensembl.
```
To use other BioMart datasets, simply provide their name. E.g. `drerio_gene_ensembl` (Zebrafish), `rnorvegicus_gene_ensembl` (Rat).

`release`: Ensembl release to query. Default: `110` (latest as of Dec. 2023).

`saveConversion`: Saves ID-symbol conversion dataframe to global environment as an object `conversions`. Default: `TRUE`
  
## 📖 Examples
Run `IDtoSymbol` on a object with human genes. Use the latest Ensembl release, and save the conversion dataframe:
```
IDtoSymbol(
  Human_SeurObj,
  species = "human",
  release = 110,
  saveConversion = TRUE
)
```
Run `IDtoSymbol` on a object with zebrafish genes. Use Ensembl release 80, and do not save the conversion dataframe:
```
IDtoSymbol(
  Zebrafish_SeurObj,
  species = "drerio_gene_ensembl",
  release = 80,
  saveConversion = FALSE
)      
```
