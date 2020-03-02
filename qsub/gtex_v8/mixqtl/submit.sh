genelist=gtex-v8-genes-passed-qc_gene_list

TASKNAME=$genelist

if [ ! -d "logs" ]; then
  mkdir logs/
fi
if [ ! -d "gene_list" ]; then
  mkdir gene_list/
fi

cat ../../../misc_data/$TASKNAME.txt > gene_list/all.txt
cd gene_list/
# split -n 500 -a 3 -d all.txt
split -l 50 -a 3 -d all.txt $TASKNAME
cd ../

for i in `ls gene_list/$TASKNAME* | sed 's#gene_list/##g'`;
do
  if [[ -f logs/$i.out ]]
  then
    zzz=`cat logs/$i.out | grep Exit | tail -n 1 | grep 1`
    if [[ ! -z $zzz ]]
    then
      echo $i 
    else
      # continue
      echo $i
    fi
  fi
  qsub -v BATCH=$i -N $1--$i qsub_generic.qsub
  
done
