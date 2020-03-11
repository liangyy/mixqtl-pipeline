# ARGV1: a list of genmic region at each row, e.g. 1  12222 1214124
# ARGV2: VCF file
# ARGV3: output prefix 
# ARGV4: exclude string, e.g. EUR_AF<0.01

counter=1
for i in `cat $1 | sed 's#\t#-x-#g'`
do
  line=(`echo $i | sed 's#-x-# #g'`)
  region="${line[0]}":"${line[1]}"-"${line[2]}"
  outfile=$3."${line[3]}".gz
  if [[ -f $outfile ]]
  then 
    echo $outfile exists, skip
  else
    bcftools view -r $region -e $4 $2 | grep -v '##' | gzip > $outfile
    echo finish $outfile
  fi
  ((counter++))
done
