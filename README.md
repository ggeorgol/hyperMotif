# TF_motif_enrichment

<h3>Map transcription factor binding motifs to non-overlapping genomic regions and perform hypergeometric over/under representation test between groups</h3>

<h4>Prerequisites:</h4>
<a href='https://github.com/samtools/htslib/releases/download/1.12/htslib-1.12.tar.bz2'>htslib</a>
<br>
<a href="https://bedops.readthedocs.io/en/latest/">bedops</a>
<br>
R
<br>

Input file format: 
1. bed file with non-overlapping genomic regions where a fourth column is the ID for your groups.
2. motifs .gz file and accompanying tabix

example:

<table>
  <tr>
    <th>chr</th>
    <th>start</th>
    <th>stop</th>
    <th>group_id</th>
  </tr>
  <tr>
    <td>chr1</td>
    <td>123456</td>
    <td>123465</td>
   <td>group_0</td>
  </tr>
  <tr>
    <td>chr1</td>
    <td>654321</td>
    <td>654432</td>
   <td>group_1</td>
  </tr>
</table>

In order to run the script in your local directory follow these steps:

1.    `mkdir ~/my/directory` #optional: make a new directory to run your script
2.    `cd ~/my/directory` #enter the directory
3.    make sure your bed file is in the directory
4.    `cp /home/ggeorgol/scripts/hypergeo_motif_enrichment.sh ./` #make a copy to the first part of the script
5.    `cp /home/ggeorgol/scripts/hypergeo_motif_enrichment.R ./` #make a copy to the second part of the script
6.    `wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz` #Copy motif archetype .gz file
7.    `wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz.tbi` #Copy the tabix index file
8.    `./hypergeo_motif_enrichment.sh test.bed hg38.archetype_motifs.v1.0.bed.gz` #run the script

The progress of the script will appear on the screen. Takes <5 min to run for ~100k elements. The results table should appear in your folder: `enrichment_results.txt`
