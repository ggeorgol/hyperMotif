#!/usr/bin/env Rscript

pkgs = c('data.table','Matrix')

for (pkg in pkgs) {

	if (!require(pkg, character.only = TRUE)) {
    print(sprintf("Installing package %s", pkg))
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

results = data.frame()

for(group in groups) {
    
    test_regions = input$V4[ input$V5 == group ]

    if (ref_group == 'rest') {

    	ref_regions = input$V4[ input$V5 != group ]

    } else {

    	ref_regions = input$V4[ input$V5 == ref_group ]

    }
    
    query = t(motif_mat[test_regions, ])
    ref = t(motif_mat[ref_regions, ])
    
    freqs_query = rowSums(query)/sum(rowSums(query))
    freq_ref = rowSums(ref)/sum(rowSums(ref))
    
    diff_freq = log2(freqs_query)-log2(freq_ref)

    freq = freqs_query[motifs]
    q = rowSums(query[motifs,]) # number of white balls drawn
    m = q + rowSums(ref[motifs,]) # total number of white balls
    n = sum(rowSums(query)) + sum(rowSums(ref)) - m # total number of black balls
    k = sum(rowSums(query)) # number of balls drawn
    
    p = ifelse(diff_freq > 0, 
              phyper(q-1, m, n, k, lower.tail = FALSE),
              phyper(q, m, n, k, lower.tail = TRUE))
    
    tmp = data.frame("motif_name" = motifs, 
                     "l2fc" = diff_freq, 
                     "freq" = freq, 
                     "p_val" = p, 
                     "fdr" = NA, 
                     "counts_in_cluster" = q, 
                     "total_counts" = m, 
                     "elements_in_cluster" = k, 
                     "group_id" = paste0(group,'_vs_',ref_group))
    
    results = rbind(results, tmp)

}

results$fdr = p.adjust(results$p_val, method = 'BH')
results = results[order(results$group_id, -results$l2fc),]

write.table(results, 'enrichment_results.txt', col.names = TRUE, row.names = FALSE, quote = FALSE, sep = '\t')
