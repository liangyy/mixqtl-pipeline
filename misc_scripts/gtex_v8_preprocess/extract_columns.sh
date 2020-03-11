# bash extract_columns.sh [list_of_column_to_extract] [input]
# print the columns to STDOUT

awk 'FNR==NR{cols[$1]=$1;next}{
  if(FNR==1) {
      for (i=1; i<=NF; i++) {
          ix[$i] = i
      }

  }
  if(FNR>0) {
      for (col in cols) {
        if(col in ix) {
          printf("%s\t", $ix[col])
        }
      }
      printf("\n");
  }
}' $1 $2
