# hyperMotif

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
   <td>groupA</td>
  </tr>
  <tr>
    <td>chr1</td>
    <td>654321</td>
    <td>654432</td>
   <td>groupB</td>
  </tr>
</table>

<h4>How to run</h4>

1.    Make a new directory to run your script (optional)<br>`mkdir ~/my/directory` #optional: 
2.    Enter the directory<br>`cd ~/my/directory`
3.    Make sure your bed file is in the directory<br>`mv regions.bed ~/my/directory/`
4.    `clone` this repository into your directory<br>`git clone https://github.com/ggeorgol/hyperMotif`
5.    Download human TF motif archetypes mapped to hg38 .gz file<br>`wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz`
6.    Download the tabix index file<br>`wget https://resources.altius.org/~jvierstra/projects/motif-clustering/releases/v1.0/hg38.archetype_motifs.v1.0.bed.gz.tbi`
7.    Run the script<br>`./hyperMotif.sh -b regions.bed -r rest -m hg38.archetype_motifs.v1.0.bed.gz -o outDir`

The progress of the script will appear on the screen. Takes <5 min to run for ~100k elements. The results table should appear in your folder: `enrichment_results.txt`

```
Usage:
	-b  A 4-column BED file where 4th column is the group assignment
	-r  The reference group. Should be one of the available groups or set to 'rest'
	    to compare against the rest of the groups
	-m  The motif scans file
	-o  The output directory
```

<h4>Output</h4>

The output table consists of 9 columns explained below:

<table>
  <tr>
    <th>column name</th>
    <th>explanation</th>
  </tr>
   <tr>
    <td>motif_name</td>
    <td>Name of <i>i</i>-th archetype motif</td>
  </tr>
  <tr>
    <td>l2fc</td>
    <td>Log2 Fold-change in <i>i</i>-th motif frequency over the reference</td>
  </tr>
  <tr>
    <td>freq</td>
    <td><i>i</i>-th motif frequency in query</td>
  </tr>
  <tr>
    <td>p_val</td>
    <td>Hypergeometric test p-value</td>
  </tr>
  <tr>
    <td>fdr</td>
    <td>Benjamini-Hochberg corrected p-value</td>
  </tr>
  <tr>
    <td>motif_counts_in_test</td>
    <td><i>i</i>-th motif counts in query</td>
  </tr>
  <tr>
  <tr>
    <td>motif_counts_in_reference</td>
    <td><i>i</i>-th motif counts in the reference</tb>
  </tr>
  <tr>
    <td>total_motif_in_test</td>
    <td>All motif counts in query</td>
  </tr>
  <tr>
    <td>elements_in_cluster</td>
    <td>Total motifs in query</td>
  </tr>
  <tr>
    <td>contrast</td>
    <td>Contrast name in the form of "groupA_vs_groupB"</td>
  </tr>
