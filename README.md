# TF_motif_enrichment

######################################################
#####        HYPERGEOMETRIC ENRICHMENT TEST      #####
##### FOR TF BINDING MOTIFS  IN GENOMIC REGIONS  #####
#####      (c) GRIGORIOS GEORGOLOPOULOS 2020     #####
######################################################

Input file format: 
1. bed file with non-overlapping genomic regions where a fourth column is the ID for your groups.
2. motifs .gz file.

example:

`chr1    123456    123465    0\n
 chr1    654321    654432    1`


In order to run the script in your local directory follow these steps:

1.    mkdir ~/my/directory #optional: make a new directory to run your script
2.    cd ~/my/directory #enter the directory
3.    make sure your bed file is in the directory
4.    cp /home/ggeorgol/scripts/hypergeo_motif_enrichment.sh ./ #make a copy to the first part of the script
5.    cp /home/ggeorgol/scripts/hypergeo_motif_enrichment.sh ./ #make a copy to the second part of the script
6.    wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz #make a link to the Jeff's archetype .gz file
7.    wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz.tbi #make a link to the tabix index file
8.    ./hypergeo_motif_enrichment.sh test.bed hg38.archetype_motifs.v1.0.bed.gz #run the script

The progress of the script will appear on the screen. Takes about 6 min to run for ~100k elements. The results table should appear in your folder: motif_hypergeometric_enrichment_results.txt

If you want to run the script again, make sure your new bed file is in that directory and start from step 8 directly

