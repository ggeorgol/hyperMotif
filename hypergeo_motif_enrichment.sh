#!/bin/bash

module load htslib
module load bedops
module load R/3.6.1

TEMPDIR=./tmp_motif_enrichment/

mkdir -p $TEMPDIR

REGIONS=$1
REF=$2
MOTIFS=$3

NF=`awk '{print NF; exit}' $REGIONS`

if (("$NF" < "4")); then
	echo "A BED file with 4 columns is required" 1>&2

	exit 1
fi

if [ "$REF" == "rest" ];
then
	echo 'Compare enchrichment against' $REF
else
	if grep -Rq $REF $REGIONS;
	then
		echo 'Compare enchrichment against' $REF
	else
		echo 'Please select one of:' `cut -f 4 $REGIONS | sort | uniq | tr '\n' '\ '`
		exit 1
	fi
fi

awk -F'\t' '{print $1 FS $2 FS $3 FS FNR FS $4;}' $REGIONS > $TEMPDIR/regions.bed

echo $(date +"%Y-%m-%d %T %Z") "Mapping motifs to query"

cut -f 1-3 $REGIONS | sort-bed - | tabix -R - $MOTIFS | sort-bed - > $TEMPDIR/motifs_mapped_to_query.txt

echo $(date +"%Y-%m-%d %T %Z") "Assigning DHS index to mapped motifs"

cut -f 1-4 $TEMPDIR/motifs_mapped_to_query.txt | bedmap --ec --echo --echo-map-id --skip-unmapped --delim '\t' - $TEMPDIR/regions.bed > $TEMPDIR/motifs_to_region_index.txt

RINPUT=$TEMPDIR/motifs_to_region_index.txt

Rscript ./hypergeo_motif_enrichment.R $RINPUT $TEMPDIR/regions.bed $REF

#rm -r $TEMPDIR
