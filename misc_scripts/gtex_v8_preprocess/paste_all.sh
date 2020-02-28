files=("${@: 2}")
n=${#files[@]}
output=$1
zcat ${files[0]} > $output.tmp.0
for (( j=0; j<${#files[@]}-1; j++))
  do
    filei=${files[$((j+1))]}
    # echo $filei
    next=$((j+1))
    paste -d "\t" $output.tmp.$j <(zcat $filei | cut -f 2-) > $output.tmp.$next
    rm $output.tmp.$j
  done
cat $output.tmp.$((n-1)) | gzip > $output
rm $output.tmp.$((n-1))
