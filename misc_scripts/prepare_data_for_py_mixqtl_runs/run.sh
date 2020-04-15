# input data
## they are in the same data folder
DATAdir=/vol/bmd/yanyul/UKB/GTExV8
ASEmat=ase-Whole_Blood.txt.gz
TRCmat=trc-Whole_Blood.txt.gz
LIBvec=GTEx_Analysis_2017-06-05_v8_Annotations_SampleAttributesDS.txt
COVARmat=covariate-combined.txt
GENOTYPEvcf=GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.vcf.gz

# prepare matrices
python prepare_matrices.py \
  --ase-matrix $DATAdir/$ASEmat \
  --trc-matrix $DATAdir/$TRCmat \
  --libsize $DATAdir/$LIBvec \
  --covariate-matrix $DATAdir/$COVARmat \
  --outdir $DATAdir/processed
  
# prepare genotypes
outprefix=GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze
python prepare_genotypes.py \
  --genotype-input $DATAdir/$GENOTYPEvcf \
  --genotype-out-prefix $outprefix \
  --outdir $DATAdir/processed
