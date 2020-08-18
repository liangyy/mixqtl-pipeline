# e = read.delim2('integrated_call_samples_v2.20130502.ALL.ped', stringsAsFactors=F, header = T)
e = read.delim2('integrated_call_samples_v3.20200731.ALL.ped', stringsAsFactors=F, header = T)

e = e[ e$phase.3.genotypes == 1, ]
# eur_amr = c('CEU', 'TSI', 'FIN', 'GBR', 'IBS', 'MXL', 'PUR', 'CLM', 'PEL')
eur = c('CEU', 'TSI', 'FIN', 'GBR', 'IBS')
f = e[ e$Population %in% eur, ]
write.table(f$Individual.ID, 'EUR.sample_list_in_phase3.txt', col = F, row = F, quo = F)
