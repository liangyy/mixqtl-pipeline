# misc functions for analysis folder

fill_in_na_pval = function(pval) {
  out = pval
  num_na = sum(is.na(pval))
  out[is.na(pval)] = runif(num_na)
  out
}

is_sig = function(pval, alpha = 0.05) {
  pval < alpha
}

add_new_name_by_map = function(col, map) {
  out = rep(NA, length(col))
  for(i in 1 : nrow(map)) {
    out[col == map[i, 1]] = map[i, 2]
  }
  out
}
