# 1. download from website: https://osf.io/6y9td/
# 2. liftover from hg19 to hg38
# 3. map to GTEx ID


# download
full=https://osf.io/vxfk3/download
fullfile=SuRE_SNP_table_LP190708.txt.gz


if [[ ! -f $fullfile ]]; then
  wget -O $fullfile $full
fi

# liftover
chainfile=hg19ToHg38.txt.gz
if [[ ! -f $chainfile ]]; then
  wget -O $chainfile https://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
fi
myscript=/Users/yanyul/Documents/repo/github/misc-tools/liftover_snp/liftover_snp.py  # available at https://github.com/liangyy/misc-tools/tree/master/liftover_snp

if [[ ! -f hg38-$fullfile ]]; then
  python $myscript \
    --input $fullfile \
    --chr_col 1 \
    --pos_col 3 \
    --liftover_chain $chainfile \
    --input_delim tab \
    --if_with_chr 1 \
    --out_txtgz hg38-$fullfile
fi 

# map
myscript=/Users/yanyul/Documents/repo/github/misc-tools/map_by_lookup_table/map_by_lookup_table.py  # available at https://github.com/liangyy/misc-tools/blob/master/map_by_lookup_table
lookuptab=/Users/yanyul/Desktop/prs/GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.lookup_table.txt.gz  # available at https://storage.googleapis.com/gtex_analysis_v8/reference/GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.lookup_table.txt.gz

if [[ ! -f mapped-$fullfile ]]; then
  python $myscript \
    --input hg38-$fullfile \
    --chr_col 16 \
    --pos_col 17 \
    --ref_col 14 \
    --alt_col 15 \
    --effect_col 3 \
    --lookup_table $lookuptab \
    --lookup_chr_col 1 \
    --lookup_pos_col 2 \
    --lookup_ref_col 4 \
    --lookup_alt_col 5 \
    --lookup_snpid_col 3 \
    --out_txtgz mapped-$fullfile \
    --include_ambiguious
fi

# output record:
# 
# Finished scanning lookup table:  /Users/yanyul/Desktop/prs/GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.lookup_table.txt.gz
# other invalid (long ref or alt)	1
# not shown	477339
# exact match	5421366
# flipped strand	8801
# flipped ref/alt	11390
# flipped strand and ref/alt	342
# Ambiguious SNP (T/A or G/C SNP)	907669
