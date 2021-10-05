# TF_motif_enrichment

<h3>Map transcription factor binding motifs to non-overlapping genomic regions and perform hypergeometric over/under representation test between groups</h3>

<h4>Prerequisites</h4>

<a href="http://www.htslib.org/download/">htslib</a><br>
<a href="https://bedops.readthedocs.io/en/latest/">bedops</a><br>
R

The speed of this workflow depends on the `fread` function from the R <a href="https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html">`data.table` package</a>
<br>
<h4>Arguments:</h4>

1. bed file with non-overlapping genomic regions where a fourth column is the ID for your groups.
2. Specify the reference group which to compare each of the available groups. Either `rest` to compare against all groups or specify a `group_id`
3. A .gz file with transcription factor motifs mapped to the genome. (Tabix index must also be included in the same directory)

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

1.    Make a new directory to run your script (optional)<br>`mkdir ~/my/directory` #optional: 
2.    Enter the directory<br>`cd ~/my/directory`
3.    Make sure your bed file is in the directory
4.    `clone` this repository into your directory<br>`git clone https://github.com/ggeorgol/TF_motif_enrichment`
5.    Download human TF motif archetypes mapped to hg38 .gz file<br>`wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz`
6.    Download the tabix index file<br>`wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz.tbi`
7.    Run the script<br>`./hypergeo_motif_enrichment.sh test.bed rest hg38.archetype_motifs.v1.0.bed.gz`

The progress of the script will appear on the screen. Takes <5 min to run for ~100k elements. The results table should appear in your folder: `enrichment_results.txt`

The output table consists of 9 columns explained below:

<table>
  <tr>
    <th>chr</th>
    <th>start</th>
    <th>stop</th>
    <th>group_id</th>
  </tr>
