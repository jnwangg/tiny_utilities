import os
import argparse
import anndata as ad

def ConcatMatrices(inDir, outDir):
   os.makedirs(outDir, exist_ok=True)

   objList = {}
   for sub, _, files in os.walk(inDir):
       if "counts_unfiltered" in sub and "adata.h5ad" in files:
           objPath = os.path.join(sub, "adata.h5ad")
           sample = os.path.basename(os.path.dirname(sub))
           objList[sample] = ad.read_h5ad(objPath)

   objConcat = ad.concat(objList, join="outer", label="sample", index_unique="-")

   output_filename = os.path.join(outDir, "concatenated.h5ad")
   objConcat.write(output_filename)


if __name__ == "__main__":
   parser = argparse.ArgumentParser(description="Aggregate multiple count matrices from kallisto-bustools output.")
   parser.add_argument("inDir", type=str, help="Input directory with kallisto-bustools output.")
   parser.add_argument("outDir", type=str, help="Output directory to store concatenated Anndata object.")
   args = parser.parse_args()

   ConcatMatrices(args.inDir, args.outDir)
