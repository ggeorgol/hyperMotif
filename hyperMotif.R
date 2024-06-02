#!/usr/bin/env Rscript

pkgs <- c('data.table','Matrix', 'tidyverse')

for (pkg in pkgs) {

	if (!require(pkg, character.only = TRUE)) {
    print(sprintf("Installing package %s", pkg))
	install.packages(pkg)

	suppressMessages(library(pkg, character.only = TRUE))
    
	} else {
        suppressMessages(library(pkg, character.only = TRUE))
	}

}

options(scipen = 4)

args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1] #"enrichment_all_motifs"
ref_group <- args[2]

motifs_to_regions <- file.path(outdir, "tmp/motifs_to_region_index.txt")
regions <- file.path(outdir, "tmp/regions.bed")

message(paste0(Sys.time(),':',' Reading motif matches'))

master <- fread(motifs_to_regions, sep = '\t', stringsAsFactors = F, data.table = F)


#### Fix overlapping matches ####

#if (sum(grepl('\\;', master$V5)>0)) {
#    oo = master[grep('\\;',master$V5),5]
#    oo = oo[seq(1, length(oo),by = 2)]
#    oo = unlist(strsplit(oo,split = '[;]'))
#    master[grep('\\;',master$V5),5] = oo
#}

message(paste0(Sys.time(),':',' Separating motifs overlapping multiple peaks'))

master <- master %>% 
mutate(id = paste(V1,V2,V3,V4)) %>% 
filter(!duplicated(id)) %>% 
separate_rows(V5,sep = ';') 

motifs <- unique(sort(master$V4))

input <- fread(regions, sep = '\t', stringsAsFactors = F, 
data.table = F, select = 1:5)

groups <- unique(sort(input$V5))
test_groups <- setdiff(groups, ref_group)

################################################
#####        Calculate counts matrix       #####
################################################

message(paste0(Sys.time(),':',' Computing DHS by Motif count matrix'))

motif_mat <- Matrix::Matrix(table(master[,c(5,4)]), sparse = T)

################################################
##### Calculate frequency and fold-changes #####
################################################

results <- data.frame()

for(group in test_groups) {

    message(paste0(Sys.time(),':',' Computing frequency and fold-changes for group ',group,''))
    
    test_regions <- input$V4[ input$V5 == group ]
    test_regions <- intersect(master$V5, test_regions)

    if (ref_group == 'rest') {

    	ref_regions <- input$V4[ input$V5 != group ]

    } else {

    	ref_regions <- input$V4[ input$V5 == ref_group ]

    }

    ref_regions <- intersect(master$V5, ref_regions)
    
    query <- t(motif_mat[test_regions, ])
    ref <- t(motif_mat[ref_regions, ])
    
    freqs_query <- rowSums(query)/sum(rowSums(query))
    freq_ref <- rowSums(ref)/sum(rowSums(ref))
    
    diff_freq <- log2(freqs_query)-log2(freq_ref)

    freq <- freqs_query[motifs]
    q <- rowSums(query[motifs,]) # number of white balls drawn
    m <- q + rowSums(ref[motifs,]) # total number of white balls
    n <- sum(rowSums(query)) + sum(rowSums(ref)) - m # total number of black balls
    k <- sum(rowSums(query)) # number of balls drawn
    
    p <- ifelse(diff_freq > 0, 
              phyper(q-1, m, n, k, lower.tail = FALSE),
              phyper(q, m, n, k, lower.tail = TRUE))
    
    tmp <- data.frame("motif_name" = motifs, 
                     "log2Ratio" = diff_freq, 
                     "freq" = freq, 
                     "pval" = p, 
                     "fdr" = NA, 
                     "motif_counts_in_test" = q, 
                     "motif_counts_in_reference" = m - q, 
                     "total_motifs_in_test" = k, 
                     "contrast" = paste0(group,'_vs_',ref_group))
    
    results <- rbind(results, tmp)

}

results <- results %>% 
mutate(fdr = p.adjust(pval, method = 'BH')) %>%
arrange(contrast, -log2Ratio)

#print(results)
write.table(results, file.path(outdir,"/enrichment_results.txt"), 
col.names = TRUE, row.names = FALSE, quote = FALSE, sep = '\t')

message(paste0(Sys.time(),':',' Completed successfully!'))
