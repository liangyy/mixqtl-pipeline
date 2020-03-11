mkdir -p subsample_whole_blood
Rscript gen_indiv_subset.R -i /gpfs/data/gtex-group/v8/59349/gtex/exchange/GTEx_phs000424/exchange/analysis_releases/GTEx_Analysis_2017-06-05_v8/eqtl/GTEx_Analysis_v8_eQTL_covariates/Whole_Blood.v8.covariates.txt -o subsample_whole_blood/indiv_subset -n 10
