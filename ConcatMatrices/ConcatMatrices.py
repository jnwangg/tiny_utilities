import os
import argparse
import anndata as ad

def ConcatMatrices(inDir, outDir, colLabel, outFile):
   os.makedirs(outDir, exist_ok=True)

   objList = {}
   for sub, _, files in os.walk(inDir):
       if "counts_unfiltered" in sub and "adata.h5ad" in files:
           objPath = os.path.join(sub, "adata.h5ad")
           sample = os.path.basename(os.path.dirname(sub))
           objList[sample] = ad.read_h5ad(objPath)

   objConcat = ad.concat(objList, join="outer", label=colLabel, index_unique="-")

   output_filename = os.path.join(outDir, outFile)
   objConcat.write(output_filename)


if __name__ == "__main__":
   parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                    description="Concatenates multiple count matrices from kallisto-bustools output. \
                                    Produces a concatenated Anndata object.")

   parser.add_argument("inDir", type=str,
                       help="input directory with kallisto-bustools output.")
   parser.add_argument("outDir", type=str,
                       help="output directory to store concatenated anndata object")
   parser.add_argument("-l", "--label", type=str, metavar="", default="sample",
                       help="column label for the original source of each matrix")
   parser.add_argument("-o", "--out", type=str, metavar="", default="concat.h5ad",
                       help="name to use for concatenated anndata object")

   args = parser.parse_args()

   ConcatMatrices(args.inDir, args.outDir, args.label, args.out)
