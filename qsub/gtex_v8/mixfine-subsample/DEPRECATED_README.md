This folder is to run sub-sampling on a random subset of genes

# Workflow in general

The workflow is as follow:

1. Generate a group of files with each one of them containing the randomly selected individual IDs (by fraction). *E.g.*: `test-indiv-folder/`
2. Generate a list of genes to work on. *E.g.*: `test-gene-list.txt`

Note that 1 and 2 should be done in tissue-specific manner since different tissues may contain different set of individuals and different expressed genes.

3. For each gene, specify the `outdir` to a specific folder and run fine-mapping with all files in step 1

This design is for efficiency purpose since the same input gene-level file required by fine-mapping with subsetting files in step 1. To further parallelize the computation, the files in step 1 can be split into groups (into separate folder) and run.

# Script

```
$ bash run_by_gene.sh
```

Example submission `whole_blood_submit.sh`

Pack all RDS's

```
$ bash submit_pack.sh whole_blood-mixfine:whole_blood-nefine ../../../data/gene_list_whole_blood_for_subsampling.txt ../../../data_for_subsampling/whole_blood date-10-02-19 /home/t.cri.yliang/scratch/mixFine/subsampling
```
