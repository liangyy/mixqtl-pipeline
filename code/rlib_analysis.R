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

inclusion_curve = function(is_true, first_n = 50) {
  nsig = sum(is_true)
  is_true_first = is_true[1 : first_n]
  return(data.frame(number_of_signals = 1 : length(is_true_first), inclusion_rate = cumsum(is_true_first) / nsig))
}

trim_dot = function(str) {
  unlist(lapply(strsplit(as.character(str), '\\.'), function(x) { x[1] }))
}

my_qqplot = function(pval, group) {
  df = data.frame(pval = pval, grp = group)
  df = df %>% group_by(grp) %>% mutate(pval_obs = pval[order(pval)], pval_exp = (1 : length(pval)) / length(pval)) %>% ungroup()
  df$pval_obs[df$pval_obs < 1e-50] = 1e-50
  p = df %>% ggplot() + geom_point(aes(x = -log10(pval_exp), y = -log10(pval_obs), color = grp))
  p
}
