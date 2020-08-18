# take a gene list and a config
# split gene list into N batches
# qsub (#genes / N) jobs where each one loop over the corresponding gene list batch

# ARGV1: gene list
# ARGS2: N genes per batch
# ARGV3: config file name, config.[name].yaml, separate by :
# ARGV4: output log/gene list folder name

genelist=gtex-v8-genes-passed-qc_gene_list  # $1
# nbatch=$2
# config=$3
# outdir=$4

# mkdir -p $outdir
mkdir -p logs
mkdir -p gene_list

cat ../../../misc_data/$genelist.txt > gene_list/all.txt
cd gene_list/
# split -n 500 -a 3 -d all.txt
split -l 50 -a 3 -d all.txt $genelist
cd ../

for i in `ls gene_list/$genelist* | sed 's#gene_list/##g'`
do
  if [[ -f logs/prep_gene--$i.out ]]
  then
    e=`cat logs/prep_gene--$i.out | grep Exit | tail -n 1 | grep 1`
    if [[ -z $e ]]
    then
      continue
    else
      qsub -v GENELIST=../../qsub/gtex_v8/mixfine/gene_list/$i,MYID=$i -N prep-$i prepare_genes.qsub
    fi
  else
    qsub -v GENELIST=../../qsub/gtex_v8/mixfine/gene_list/$i,MYID=$i -N prep-$i prepare_genes.qsub
  fi
done
