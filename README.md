# TF_motif_enrichment

<h3>Map transcription factor binding motifs to non-overlapping genomic regions and perform hypergeometric over/under representation test between groups</h3>

<h4>Prerequisites:</h4>
<a href="http://www.htslib.org/download/">htslib</a>
<br>
<a href="https://bedops.readthedocs.io/en/latest/">bedops</a>
<br>
R
<br>
<p>
The speed of this workflow depends on the `fread` function from the <a href="https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html">`data.table` package</a>
  </p>
<br>
<h4>Arguments:</h4>
1. bed file with non-overlapping genomic regions where a fourth column is the ID for your groups.
2. Specify the reference group which to compare each of the available groups. Either `rest` to compare against all groups or specify a `group_id`
3. A .gz file with transcription factor motifs mapped to the genome and the accompanying tabix

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
8.    `./hypergeo_motif_enrichment.sh test.bed rest hg38.archetype_motifs.v1.0.bed.gz` #run the script

The progress of the script will appear on the screen. Takes <5 min to run for ~100k elements. The results table should appear in your folder: `enrichment_results.txt`
