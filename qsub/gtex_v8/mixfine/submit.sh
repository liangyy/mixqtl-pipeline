# take a gene list and a config
# split gene list into N batches
# qsub N jobs where each one loop over the corresponding gene list batch

# ARGV1: gene list
# ARGS2: N batches
# ARGV3: config file name, config.[name].yaml, separate by :
# ARGV4: output log/gene list folder name

genelist=gtex-v8-genes-passed-qc_gene_list  # $1
METHODS=mixfine:nefine
# nbatch=$2
# config=$3
# outdir=$4

# mkdir -p $outdir
mkdir -p logs
mkdir -p gene_list

# Skip the following since they has been run by submit_prepare.sh
# cat ../../../misc_data/$genelist.txt > gene_list/all.txt
# cd gene_list/
# # split -n 500 -a 3 -d all.txt
# split -l 50 -a 3 -d all.txt $genelist
# cd ../

for i in `ls gene_list/$genelist* | sed 's#gene_list/##g'`
do
  echo qsub -v GENELIST=../../qsub/gtex_v8/mixfine/gene_list/$i,MYID=$i,CONFIG=$METHODS -N run-$i run.qsub
done
