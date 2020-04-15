# input data
## they are in the same data folder
GTExDATAdir=/vol/bmd/yanyul/UKB/GTExV8
PipeDATAdir=/vol/bmd/yanyul/UKB/GTExV8/original_data_from_mixqtl_pipeline
ASEmat=ase-Whole_Blood.txt.gz
TRCmat=trc-Whole_Blood.txt.gz
LIBvec=GTEx_Analysis_2017-06-05_v8_Annotations_SampleAttributesDS.txt
COVARmat=covariate-combined.txt
GENOTYPEvcf=GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.SHAPEIT2_phased.MAF01.vcf.gz

# prepare matrices
echo python prepare_matrices.py \
  --ase-matrix $PipeDATAdir/$ASEmat \
  --trc-matrix $PipeDATAdir/$TRCmat \
  --libsize $GTExDATAdir/$LIBvec \
  --covariate-matrix $PipeDATAdir/$COVARmat \
  --outdir $GTExDATAdir/processed
  
# prepare genotypes
outprefix=GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.SHAPEIT2_phased.MAF01
python prepare_genotypes.py \
  --genotype-input $GTExDATAdir/$GENOTYPEvcf \
  --genotype-out-prefix $outprefix \
  --outdir $GTExDATAdir/processed/genotype_in_parquet 
  # --chrs 20
