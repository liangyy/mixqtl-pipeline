# ARGV1: geneid

geneid=$1

echo $geneid

if [[ ! -f perm-input.$geneid.1.rds ]]; then
  Rscript ../../code/gtex_v8_split_into_batch.R --expression /scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-preprocess/expression/merge-Whole_Blood.rds --genotype /scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-preprocess/genotype/$geneid.txt.gz --output_prefix perm-input.$geneid. --nbatch 1 --gene $geneid
fi

Rscript ../../code/gtex_v8_mixqtl_perm_x.R \
  --data perm-input.$geneid.1.rds \
  --cov /scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-preprocess/peer/Whole_Blood/covariate-combined.txt \
  --output perm-$geneid.mixqtl_permute.rds
