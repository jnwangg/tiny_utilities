import os
import argparse
import anndata as ad

def ConcatMatrices(inDir, outDir, colLabel, outFile):
    """
    Concatenates multiple count matrices from kallisto-bustools output.
    Produces a concatenated Anndata object.

    Args:
        inDir (str): Input directory with kallisto-bustools output.
        outDir (str): Output directory to store concatenated anndata object.
        colLabel (str): Column label for the original source of each matrix.
        outFile (str): Name to use for concatenated anndata object.
    """
    # Create output dir, if it does not already exist.
    os.makedirs(outDir, exist_ok=True)

    # Store mapping of subdir name to matrice.
    objList = {}

    # Walk through each subdir. For every count matrice found:
    for sub, _, files in os.walk(inDir):
        if "counts_unfiltered" in sub and "adata.h5ad" in files:
            # Read in count matrice. Map matrice to the name of its subdir.
            objPath = os.path.join(sub, "adata.h5ad")
            sample = os.path.basename(os.path.dirname(sub))
            objList[sample] = ad.read_h5ad(objPath)

    # Concatenate matrices, making indices unique if needed.
    objConcat = ad.concat(objList, join="outer", label=colLabel, index_unique="-")

    # Save concatenated object.
    output_filename = os.path.join(outDir, outFile)
    objConcat.write(output_filename)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                        description="Concatenates multiple count matrices from \
                                        kallisto-bustools output. Produces a concatenated Anndata object.")

    # Positional arguments.
    parser.add_argument("inDir", type=str,
                        help="input directory with kallisto-bustools output.")
    parser.add_argument("outDir", type=str,
                        help="output directory to store concatenated anndata object")

    # Optional arguments.
    parser.add_argument("-l", "--label", type=str, metavar="", default="sample",
                        help="column label for the original source of each matrix")
    parser.add_argument("-o", "--out", type=str, metavar="", default="concat.h5ad",
                        help="name to use for concatenated anndata object")

    # Parse arguments and concatenate.
    args = parser.parse_args()
    ConcatMatrices(args.inDir, args.outDir, args.label, args.out)
