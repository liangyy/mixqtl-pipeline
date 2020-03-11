# mixqtl-pipeline

## Overview

This repository reproduces the results for paper [link](https://github.com/liangyy/paper-mixqtl/blob/master/new_draft/main.pdf)

It contains pipelines for

* Simulation
* mixQTL, mixPred, and mixFine runs on simulated data
* mixQTL and mixFine runs on GTEx V8 data (along with the pre-processing steps)

## Dependencies

It reproduces mixQTL results using `mixqtl` R package. To install, do

```
devtools::install_github('liangyy/mixqtl@reproduce')
```

The pipeline is built using `snakemake`. The full conda environment is coming in the future. 

## Directory structure

* `pipeline/`: pipelines in `snakemake` 
* `code/`: scripts for the pipeline
* `qsub/`: actual jobs running `pipeline`. It specifies all dependent files and parameters to reproduce the runs
* `analysis/`: analysis and summary report of the runs

# TODO

* Pack up `misc_data` in the end.