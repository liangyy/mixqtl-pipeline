# ARGV1: MYCONFIGS (should be in this folder)
# ARGV2: gene list relative to this folder
# ARGV3: SUBSETDIR (name relative to this folder)
# ARGV4: name of pack 
# ARGV5: folder of result (after merging, not neccssary to merge though)

MYCONFIGS=config.mixfine.yaml:config.nefine.yaml  # $1
TASKNAME=gene_list_whole_blood_for_subsampling_with_qc  
# genelist=$2
SUBSETDIR=subsample_whole_blood  # $3
packname=mypack-03-08-20  # $4
outdir=/scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-results/mixfine-subsample  # $5

if [ ! -d "pack_logs" ]; then
  mkdir pack_logs/
fi

for genelist in `ls gene_list/$TASKNAME* | sed 's#gene_list/##g'`;
do
  qsub -v GENELIST=$genelist,PACKNAME=$packname,MYCONFIGS=$MYCONFIGS,OUTDIR=$outdir,SUBSETDIR=$SUBSETDIR -N $packname run_pack.qsub
done




