# ARGV1: MYCONFIGS (should be in this folder)
# ARGV2: gene list relative to this folder
# ARGV3: SUBSETDIR (name relative to this folder)
# ARGV4: name of pack 
# ARGV5: folder of result (after merging, not neccssary to merge though)

MYCONFIGS=$1
genelist=$2
SUBSETDIR=$3
packname=$4
outdir=$5

if [ ! -d "pack_logs" ]; then
  mkdir pack_logs/
fi



qsub -v GENELIST=qsub/mixfine/whole_blood/$genelist,PACKNAME=$packname,MYCONFIGS=$MYCONFIGS,OUTDIR=$outdir,SUBSETDIR=$SUBSETDIR -N $packname run_pack.qsub



