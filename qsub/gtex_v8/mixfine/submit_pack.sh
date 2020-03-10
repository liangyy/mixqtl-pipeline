# take a gene list and a config
# split gene list into N batches
# qsub N jobs where each one loop over the corresponding gene list batch


# ARGV1: config file name, config.[name].yaml, separate by :

config=mixfine:nefine  # $1
genelist=gtex-v8-genes-passed-qc_gene_list  # $2
packname=GTExV8_WholeBlood  # $3

# mkdir -p logs/

qsub -v GENELIST=../../misc_data/$genelist.txt,PACKNAME=$packname,CONFIG=$config -N pack-$packname run_pack.qsub

