# ARGV1: prefix of genotype file
# ARGV2: suffix of genotype file
# ARGV3: prefix of readcount file
# ARGV4: middle name of readcount file
# ARGV5: suffix of readcount file
# ARGV6: outdir

genoprefix=$1
genosuffix=$2
rcprefix=$3
rcmiddle=$4
rcsuffix=$5
outdir=$6

## create config and log folder
mkdir -p configs/
mkdir -p logs/

## declare an array of relative abundance
declare -a theta=("5e-5" "2.5e-5" "1e-5" "5e-6" "2.5e-6" "1e-6")
## declare an array of sample size
declare -a samplesize=("100" "200" "300" "400" "500")
## declare an array of methods to be used
declare -a method=("mixfine" "trcfine")

for t in "${theta[@]}"
do
  for s in "${samplesize[@]}"
  do
    name=samplesize$s\_x_theta$t
    samplesizename=size_$s
    for ((i = 0; i < ${#method[@]}; ++i))
    do
      m=${method[$i]}
      f=${finemap[$i]}
      logf=logs/$name-$m.out
       
      if [[ -f $logf ]]
      then 
        e=`cat $logf|grep Exit|tail -n 1|grep 1` 
        if [[ -z $e ]]
        then 
          continue
        fi
      fi 
      echo "data:
  genotype: '$genoprefix$samplesizename$genosuffix'
  readcount: '$rcprefix$name$rcmiddle$samplesizename$rcsuffix'
  M_from: 1
  M_to: 100
  name: '$name'
split:
  ntest: 2 
  ratio: 0.2
" > configs/config_$name.yaml
      qsub -v NAME=$name,METHOD=$m,OUTDIR=$outdir -N $name-$m run.qsub
    done
  done
done
