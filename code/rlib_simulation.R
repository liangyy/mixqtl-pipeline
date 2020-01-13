decompose_ase = function(df, cols) {
  df_info = df[, -cols]
  df_ase = df[, cols]
  temp_decomp = t(apply(df_ase, 1, function(x) {
    temp = str_match(x, '([0-9]+)\\|([0-9]+)')
    h1 = as.numeric(temp[, 2])
    h2 = as.numeric(temp[, 3])
    return(c(h1, h2))
  }))
  df_h1 = temp_decomp[, 1 : ncol(df_ase)]
  df_h2 = temp_decomp[, (1 + ncol(df_ase)) : (2 * ncol(df_ase))]
  df_h1 = cbind(df_info, df_h1)
  df_h2 = cbind(df_info, df_h2)
  colnames(df_h1)[cols] = colnames(df_ase)
  colnames(df_h2)[cols] = colnames(df_ase)
  return(list(h1 = df_h1, h2 = df_h2))
}

split_data_here = function(genotype, readcount, ratio = 1 / 2) {
  indivs = 1 : nrow(readcount$observed)
  ntest = floor(length(indivs) * ratio)
  test.idx = sample(indivs, size = ntest, replace = F)
  test.ind = indivs %in% test.idx

  # split readcount
  readcount_test = readcount
  readcount_test$observed = readcount_test$observed[test.ind, ]
  readcount_train = readcount
  readcount_train$observed = readcount_train$observed[!test.ind, ]

  # split genotype
  genotype_test = genotype
  genotype_test$h1 = genotype_test$h1[test.ind, ]
  genotype_test$h2 = genotype_test$h2[test.ind, ]
  genotype_train = genotype
  genotype_train$h1 = genotype_train$h1[!test.ind, ]
  genotype_train$h2 = genotype_train$h2[!test.ind, ]

  return(list(test = list(readcount = readcount_test, genotype = genotype_test), train = list(readcount = readcount_train, genotype = genotype_train)))
}

format_system_time = function(my_proc_time) {
  val = as.vector(my_proc_time)[1 : 3]
  names(val) = names(my_proc_time)[1 : 3]
  out = as.data.frame(t(val))
  rownames(out) = NULL
  return(out)
}

get_pve_here = function(y, ypred) {
  mod = lm(ypred ~ 1 + y)
  mod0 = lm(ypred ~ 1)
  sse = sum(residual(mod) ^ 2)
  sse0 = sum(residual(mod0) ^ 2)
  return(1 - sse / sse0)
}

get_spcor_here = function(y, ypred) {
  cor(y, ypred, method = 'spearman')
}

get_pcor_here = function(y, ypred) {
  cor(y, ypred, method = 'pearson')
}
