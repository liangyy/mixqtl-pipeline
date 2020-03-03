# 1. download from website: https://osf.io/6y9td/
# 2. liftover from hg19 to hg38
# 3. map to GTEx ID


# download
hepg2=https://osf.io/56nxe/download
k562=https://osf.io/qxaj3/download
hepg2file=hepg2.sign.id.LP190708.txt.gz
k562file=k562.sign.id.LP190708.txt.gz


if [[ ! -f $hepg2file ]]; then
  wget -O $hepg2file $hepg2
fi
if [[ ! -f $k562file ]]; then 
  wget -O $k562file $k562 
fi

# liftover
chainfile=hg19ToHg38.txt.gz
if [[ ! -f $chainfile ]]; then
  wget -O $chainfile https://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
fi
myscript=/Users/yanyul/Documents/repo/github/misc-tools/liftover_snp/liftover_snp.py  # available at https://github.com/liangyy/misc-tools/tree/master/liftover_snp

if [[ ! -f hg38-$hepg2file ]]; then
  python $myscript \
    --input $hepg2file \
    --chr_col 1 \
    --pos_col 3 \
    --liftover_chain $chainfile \
    --input_delim tab \
    --if_with_chr 1 \
    --out_txtgz hg38-$hepg2file
fi 

if [[ ! -f hg38-$k562file ]]; then
  python $myscript \
    --input $k562file \
    --chr_col 1 \
    --pos_col 3 \
    --liftover_chain $chainfile \
    --input_delim tab \
    --if_with_chr 1 \
    --out_txtgz hg38-$k562file
fi 

# map
myscript=/Users/yanyul/Documents/repo/github/misc-tools/map_by_lookup_table/map_by_lookup_table.py  # available at https://github.com/liangyy/misc-tools/blob/master/map_by_lookup_table
lookuptab=/Users/yanyul/Desktop/prs/GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.lookup_table.txt.gz  # available at https://storage.googleapis.com/gtex_analysis_v8/reference/GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.lookup_table.txt.gz

if [[ ! -f mapped-$hepg2file ]]; then
  python $myscript \
    --input hg38-$hepg2file \
    --chr_col 12 \
    --pos_col 13 \
    --ref_col 10 \
    --alt_col 11 \
    --effect_col 3 \
    --lookup_table $lookuptab \
    --lookup_chr_col 1 \
    --lookup_pos_col 2 \
    --lookup_ref_col 4 \
    --lookup_alt_col 5 \
    --lookup_snpid_col 3 \
    --out_txtgz mapped-$hepg2file \
    --include_ambiguious
fi
  
if [[ ! -f mapped-$k562file ]]; then
  python $myscript \
    --input hg38-$k562file \
    --chr_col 12 \
    --pos_col 13 \
    --ref_col 10 \
    --alt_col 11 \
    --effect_col 3 \
    --lookup_table $lookuptab \
    --lookup_chr_col 1 \
    --lookup_pos_col 2 \
    --lookup_ref_col 4 \
    --lookup_alt_col 5 \
    --lookup_snpid_col 3 \
    --out_txtgz mapped-$k562file \
    --include_ambiguious
fi
