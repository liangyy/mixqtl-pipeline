cat ../../../data/annotations_gencode_v26.tsv | grep 'protein_coding\|lincRNA' | cut -f 1 > protein_coding_and_lincRNA.txt
