# ARGV1: specify outdir 

## declare an array of relative abundance
declare -a theta=("5e-5" "2.5e-5" "1e-5" "5e-6" "2.5e-6" "1e-6")
## declare an array of sample size
declare -a samplesize=("100" "200" "300" "400" "500")
## ratio between mean theta and sd of theta
ratio=4

OUTDIR=$1

mkdir -p logs
mkdir -p configs

for t in "${theta[@]}"
do
  tsd=`perl -le 'print $ARGV[0] / $ARGV[1]' -- "$t" "$ratio"`
  for s in "${samplesize[@]}"
  do
    # jobname
    jobname=samplesize$s\_x_theta$t
    
    # complete parameter file
    cat param_in_common_2.yaml > configs/param_2_$jobname.yaml
    echo Nsample: "$s" >> configs/param_2_$jobname.yaml
    echo theta_mu: "$t" >> configs/param_2_$jobname.yaml
    echo theta_sd: "$tsd" >> configs/param_2_$jobname.yaml
    
    # complete config file
    cat config_in_common_2.yaml > configs/config_2_$jobname.yaml
    echo M: 100 >> configs/config_2_$jobname.yaml
    echo Nsample: "$s" >> configs/config_2_$jobname.yaml
    echo parameter_file: >> configs/config_2_$jobname.yaml
    echo '  name: '"$jobname" >> configs/config_2_$jobname.yaml
    echo '  path: ../../qsub/simulation/multi/configs/param_2_'"$jobname".yaml >> configs/config_2_$jobname.yaml
    
    # submit
    if [[ -f logs/$jobname\_2.out ]]
    then 
      e=`cat logs/$jobname\_2.out  | grep Exit | tail -n 1 | grep 0 | wc -l`;
      if [[ $e != 1 ]]
      then
        qsub -v NAME=$jobname,OUTDIR=$OUTDIR -N $jobname run_2.qsub
      fi
    else
      qsub -v NAME=$jobname,OUTDIR=$OUTDIR -N $jobname run_2.qsub
    fi
  done
done