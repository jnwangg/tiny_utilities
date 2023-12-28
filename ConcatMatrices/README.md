# ConcatMatrices
> A utility that concatenates multiple count matrices from raw kallisto-bustools output.

[![Static Badge](https://img.shields.io/badge/anndata-v0.10.3-blue)](https://github.com/scverse/anndata?tab=readme-ov-file)

## 🔧 Usage 
Run `ConcatMatrices.py -h` to see usage instructions.
```
usage: ConcatMatrices.py [-h] [-l] [-o] inDir outDir

Concatenates multiple count matrices from kallisto-bustools output. Produces a concatenated Anndata object.

positional arguments:
  inDir          input directory with kallisto-bustools output.
  outDir         output directory to store concatenated anndata object

options:
  -h, --help     show this help message and exit
  -l , --label   column label for the original source of each matrix (default: sample)
  -o , --out     name to use for concatenated anndata object (default: concat.h5ad)
```
> [!IMPORTANT]
> `ConcatMatrices` expects a simple directory structure as input. First, make sure kallisto-bustools generates count matrices as .h5ad files.
> Each subdirectory should then contain the raw output for one sample, as follows:
> ```
>InDir/
>├── SampleA/
>│   ├── counts_unfiltered/
>│   │   └── adata.h5ad
>│   └── ...
>├── SampleB/
>│   ├── counts_unfiltered/
>│   │   └── adata.h5ad
>│   └── ...
>└── ...
> ```
> Be sure to name each subdirectory descriptively! `ConcatMatrices` will automatically use subdirectory names to label
> data for each count matrix. This lets you keep track of the original source of all data in the concatenated matrix.
>
> For example, the above input directory would produce an output anndata object with the follow `obs`:
> ```
>                   sample
> Cell_1-SampleA    SampleA
> Cell_2-SampleA    SampleA
> Cell_1-SampleB    SampleB
> Cell_2-SampleB    SampleB
> Cell_3-SampleB    SampleB
> ...
> ```
  
## 📖 Examples
Run `IDtoSymbol` with default parameters:
```
ConcatMatrices.py path/to/input/ path/to/output/
```
Run `IDtoSymbol` with a custom column label and output filename:
```
ConcatMatrices.py path/to/input/ path/to/output/ -l batch -o human_concat.h5ad
```
