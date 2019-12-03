# ARGV1: specify outdir 

## declare an array of relative abundance
declare -a theta=("5e-5" "2.5e-5" "1e-5" "5e-6" "2.5e-6" "1e-6")
## declare an array of sample size
declare -a samplesize=("100" "200" "300" "400" "500")
## ratio between mean theta and sd of theta
ratio=4

OUTDIR=$1

mkdir -p logs

for t in "${theta[@]}"
do
  tsd=`perl -le 'print $ARGV[0] / $ARGV[1]' -- "$t" "$ratio"`
  for s in "${samplesize[@]}"
  do
    # jobname
    jobname=samplesize$s\_x_theta$t
    
    # complete parameter file
    cat param_in_common.yaml > configs/param_$jobname.yaml
    echo Nsample: "$s" >> configs/param_$jobname.yaml
    echo theta_mu: "$t" >> configs/param_$jobname.yaml
    echo theta_sd: "$tsd" >> configs/param_$jobname.yaml
    
    # complete config file
    echo M: 200 > configs/config_$jobname.yaml
    echo parameter_file: >> configs/config_$jobname.yaml
    echo '  name: '"$jobname" >> configs/config_$jobname.yaml
    echo '  path: ../../qsub/simulation/single/configs/param_'"$jobname".yaml >> configs/config_$jobname.yaml
    
    # submit
    qsub -v NAME=$jobname,OUTDIR=$OUTDIR -N $jobname run.qsub
  done
done