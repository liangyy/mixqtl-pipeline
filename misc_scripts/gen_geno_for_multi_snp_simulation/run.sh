# ARGV1: target folder

scriptdir=`pwd`
targetdir=$1

cd $targetdir

# download 1000G phase3 phased genotypes
if [[ ! -f ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi ]]
then 
  wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi
fi
if [[ ! -f ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz ]]
then 
  wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
fi
if [[ ! -f integrated_call_samples_v2.20130502.ALL.ped ]]
then 
  wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v2.20130502.ALL.ped
fi

# download gencode gene annotation
if [[ ! -f gencode.v32lift37.basic.annotation.gff3.gz ]]
then
  echo EEEEEEEEEEEEEEEEEE 
  wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/GRCh37_mapping/gencode.v32lift37.basic.annotation.gff3.gz
fi 

# generate eur sample list
if [[ ! -f EUR.sample_list_in_phase3.txt ]]
then 
  Rscript $scriptdir/gen_eur_sample_list.R
fi 

# format gencode gene annotation 
if [[ ! -f formatted-gene-model.gencode.v32lift37.basic.annotation.txt.gz ]]
then
  bash $scriptdir/format_gencode_gene_annotation.sh
fi

# subset vcf file to European individuals
if [[ ! -f EUR.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz ]]
then
  bcftools view -S EUR.sample_list_in_phase3.txt ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz | bgzip > EUR.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
fi
if [[ ! -f EUR.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi ]]
then
  tabix EUR.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
fi

# sample some genes from chromosome 22
if [[ ! -f selected_genes.txt ]]
then
  zcat formatted-gene-model.gencode.v32lift37.basic.annotation.txt.gz|grep chr22 > tmp-selected_genes.txt
  Rscript $scriptdir/sampling_genes.R tmp-selected_genes.txt 1000000 selected_genes.txt 200
  rm tmp-selected_genes.txt
fi 

# extract genotype 
bash $scriptdir/extract_genotype.sh \
  selected_genes.txt \
  EUR.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz \
  genotype \
  "EUR_AF<0.01|EUR_AF>0.99"


