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
