#!/usr/bin/env Rscript

pkgs = c('data.table','Matrix')

for (pkg in pkgs) {

	if (!require(pkg, character.only = TRUE)) {

	install.packages(pkg)

	library(pkg, character.only = TRUE)
    
	} else {
	
		library(pkg, character.only = TRUE)
	}

}

args = commandArgs(trailingOnly = TRUE)

options(scipen = 4)

master = fread(args[1], sep = '\t', stringsAsFactors = F, data.table = F)

motifs = unique(sort(master$V4))

input=fread(args[2], sep = '\t', stringsAsFactors = F, data.table = F, select = 1:5)

groups = unique(sort(input$V5))

ref_group = args[3]


################################################
#####        Calculate counts matrix       #####
################################################

cat(paste0(Sys.time(),':',' Computing DHS by Motif count matrix'))

motif_mat = Matrix::Matrix(table(master[,c(5,4)]), sparse = T)

################################################
##### Calculate frequency and fold-changes #####
################################################

cat(paste0(Sys.time(),':',' Computing frequency and fold-changes per group'))

results = data.frame(motif_name = NA, l2fc = NA, freq = NA, p_val = NA, fdr = NA, counts_in_cluster = NA, total_counts = NA, elements_in_cluster = NA, cluster = NA)

for(group in groups) {
    
    test_regions = input$V4[ input$V5 == group ]

    if (ref_group == 'rest') {

    	ref_regions = input$V4[ input$V5 != group ]

    } else {

    	ref_regions = input$V4[ input$V5 == ref_group ]

    }
    
    query = t(motif_mat[test_regions, ])
    ref = t(motif_mat[ref_regions, ])
    
    freq = rowSums(query)/sum(rowSums(query))
    
    diff_freq = log2(freq)-log2(rowSums(ref)/sum(rowSums(ref)))

    q = rowSums(query) # number of white balls drawn
    m = q + rowSums(ref) # total number of white balls
    n = sum(rowSums(query)) + sum(rowSums(ref)) - m # total number of black balls
    k = sum(rowSums(query)) # number of balls drawn
    
    p = phyper(q, m, n, k, lower.tail = ifelse(freq > 0, FALSE, TRUE))
    
    enr = data.frame(motif_name = motifs, 
                     l2fc = diff_freq, 
                     freq = freq, 
                     p_val = p, 
                     fdr = NA, 
                     counts_in_cluster = q, 
                     total_counts = m, 
                     elements_in_cluster = k, 
                     cluster = paste0(group,'_vs_',ref_group))
    
    results = rbind(results, enr)

}

results = results[-1,]
results$fdr = p.adjust(results$p_val, method = 'BH')
results = results[order(results$cluster, -results$l2fc),]
#results$TF_Symbol = sapply(results$motif_name, FUN = function(i){
#    
#    paste(unique(sort(arch_anno$TF_Symbol[ arch_anno$Cluster_Name == i ])), collapse = ';')
#    
#})

write.table(results, 'enrichment_results.txt', col.names = TRUE, row.names = FALSE, quote = FALSE, sep = '\t')
