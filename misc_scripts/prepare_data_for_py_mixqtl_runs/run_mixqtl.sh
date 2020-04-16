# inputs
DATAdir=/vol/bmd/yanyul/UKB/GTExV8/processed
HAPdir=/vol/bmd/yanyul/UKB/GTExV8/processed/genotype_in_parquet

## data files
HAPprefix=GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.SHAPEIT2_phased.MAF01.chr
HAPsuffix=.hap{}.parquet
LIBSIZEpattern=gtex_v8_library_size.txt.gz:SAMPID:SMMPPD
ASCpattern=allele_specific_count.hap{}.txt.gz:GENE_ID
COVARfile=covariates.txt.gz
TRCfile=total_count.bed.gz

## other files
genelist=/vol/bmd/yanyul/UKB/GTExV8/Whole_Blood.v8.egenes.txt.gz:gene_id
paramyaml=/vol/bmd/yanyul/GitHub/mixqtl-pipeline/misc_scripts/prepare_data_for_py_mixqtl_runs/param.yaml

## code directory
CODEtensorqtl=/vol/bmd/yanyul/GitHub_another/tensorqtl/tensorqtl

# output
OUTDIR=/vol/bmd/yanyul/UKB/GTExV8/mixqtl
OUTPREFIX=Whole_Blood_GTEx_eGene

# run
chromosomes=`seq 1 22`
chromosomes+=(X)
if [[ -f run_mixqtl.log ]] 
then
  rm run_mixqtl.log
fi
# chromosomes=(1)  # for test
for THISchr in ${chromosomes[@]}
do
  echo on chromosome $THISchr >> run_mixqtl.log 2>&1
  python run_py_mixqtl.py \
    --hap-file $HAPdir/$HAPprefix$THISchr$HAPsuffix \
    --libsize $DATAdir/$LIBSIZEpattern \
    --covariate-matrix $DATAdir/$COVARfile \
    --asc-matrix $DATAdir/$ASCpattern \
    --trc-matrix $DATAdir/$TRCfile \
    --param-yaml $paramyaml \
    --out-dir $OUTDIR \
    --out-prefix $OUTPREFIX \
    --tensorqtl $CODEtensorqtl \
    --chr chr$THISchr \
    --impute-trc \
    --gene-list $genelist \
    >> run_mixqtl.log 2>&1
done



