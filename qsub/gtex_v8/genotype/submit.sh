TASKNAME=gtex-v8-genes-passed-qc_gene_list

if [ ! -d "configs" ]; then
  mkdir configs/
fi
if [ ! -d "logs" ]; then
  mkdir logs/
fi
if [ ! -d "gene_list" ]; then
  mkdir gene_list/
fi

cat ../../../misc_data/$TASKNAME.txt > gene_list/all.txt
cd gene_list/
# split -n 500 -a 3 -d all.txt
split -l 200 -a 3 -d all.txt $TASKNAME
cd ../

for i in `ls gene_list/$TASKNAME* | sed 's#gene_list/##g'`;
do
  qsub -v GENELIST=../../qsub/gtex_v8/genotype/gene_list/$i,MYNAME=$i -e logs/$i.err -o logs/$i.out -N $i qsub_generic.qsub
done
