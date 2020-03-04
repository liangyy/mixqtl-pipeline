# the followings may not up to date
# only to keep a record 
# ARGV1: MYCONFIGS (should be in this folder)
# ARGV2: gene list name in ../../../data/
# ARGV3: SUBSETDIR (name relative to this folder)
# ARGV4: OUTDIR (absolute name, no / in the end)
# ARGV5: number of gene per job
# ARGV6: name of job
# ARGV7: output folder of log

MYCONFIGS=config.mixpred.yaml:config.nepred.yaml  # $1
TASKNAME=gene_list_whole_blood_for_subsampling_with_qc  # this is the subset of genes passing QC # gtex-v8-genes-passed-qc_gene_list  # $2  # gene list name
# SUBSETDIR=subsample_whole_blood  # relative path to subsampled individual IDs  # $3
# OUTDIR=/scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-results/mixpred-partition  # $4
NGENE=100  # $4
JOBNAME=mixpred-partition  # $5
OUTLOG=myrun-03-04-20  # $6

if [ ! -d "logs" ]; then
  mkdir logs/
fi
if [ ! -d "gene_list" ]; then
  mkdir gene_list/
fi

mkdir -p $OUTLOG

# ls gene_list/$TASKNAME* | head -n 1
if [ -f gene_list/$TASKNAME"000" ]; then
  # ls gene_list/$TASKNAME* | xargs rm
  echo 'exist!'
else
  cat ../../../misc_data/$TASKNAME.txt > gene_list/all.txt
  cd gene_list/
  # split -n 500 -a 3 -d all.txt
  split -l $NGENE -a 3 -d all.txt $TASKNAME
  cd ../
fi


# cat ../../../data/$TASKNAME.txt > gene_list/all.txt
# cd gene_list/
# split -n 500 -a 3 -d all.txt
# split -l $NGENE -a 3 -d all.txt $TASKNAME
# cd ../

for i in `ls gene_list/$TASKNAME* | sed 's#gene_list/##g'`;
do
  qsub -v GENELIST=$i,MYCONFIGS=$MYCONFIGS,JOBNAME=$JOBNAME,OUTLOG=$OUTLOG,OUTDIR=$OUTDIR -N $JOBNAME--$i run_by_genelist.qsub
done
