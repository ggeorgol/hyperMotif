#!/bin/bash

module load htslib
module load bedops
module load R/3.6.1

TEMPDIR=./tmp_motif_enrichment/

mkdir $TEMPDIR

INPUT=$1
MOTIFS=$2

awk -F'\t' '{print $1 FS $2 FS $3 FS FNR FS $4;}' $INPUT > $TEMPDIR/annotated_input.bed

NF=`awk '{print NF; exit}' $INPUT`

if (("$NF" < "4")); then
	echo "A BED file with 4 columns is required" 1>&2

	exit 1
fi

echo $(date +"%Y-%m-%d %T %Z") "Mapping motifs to query"

cut -f 1-3 $INPUT | sort-bed - | tabix -R - $MOTIFS | sort-bed - > $TEMPDIR/motifs_mapped_to_query.txt

echo $(date +"%Y-%m-%d %T %Z") "Assigning DHS index to mapped motifs"

cut -f 1-4 $TEMPDIR/motifs_mapped_to_query.txt | bedmap --ec --echo --echo-map-id --skip-unmapped --delim '\t' - $TEMPDIR/annotated_input.bed > $TEMPDIR/input_index_to_motifs.txt

RINPUT=$TEMPDIR/input_index_to_motifs.txt

Rscript /home/ggeorgol/scripts/hypergeo_motif_enrichment.R $RINPUT $TEMPDIR/annotated_input.bed

#rm -r $TEMPDIR
