# ARGV1: prefix of readcount file
# ARGV2: suffix of readcount file
# ARGV3: outdir

myprefix=$1
mysuffix=$2
OUTDIR=$3

mkdir -p configs
mkdir -p logs

## declare an array of relative abundance
declare -a theta=("5e-5" "2.5e-5" "1e-5" "5e-6" "2.5e-6" "1e-6")
## declare an array of sample size
declare -a samplesize=("100" "200" "300" "400" "500")

for t in "${theta[@]}"
do
  for s in "${samplesize[@]}"
  do
    # jobname
    jobname=samplesize$s\_x_theta$t
    
    # generate config file 
    echo M_from: 1 > configs/config_$jobname.yaml
    echo M_to: 200 >> configs/config_$jobname.yaml
    echo path: "$myprefix""$jobname""$mysuffix" >> configs/config_$jobname.yaml
    echo name: "$jobname" >> configs/config_$jobname.yaml
    
    # submit
    qsub -v NAME=$jobname,OUTDIR=$OUTDIR -N $jobname run.qsub
  done
done
    
