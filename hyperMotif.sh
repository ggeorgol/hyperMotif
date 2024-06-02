#!/bin/bash

#module load htslib
#module load bedops
#module load R/3.6.1

if [[ $# == 0 ]]; then
  echo "No arguments were provided. Exiting."
  echo "	Usage:"
  echo "	-b  A 4-column BED file where 4th column is the group assignment"
  echo "	-r  The reference group. Should be one of the available groups or set to 'rest' \nto compare against the rest of the groups"
  echo "	-m  The motif scans file"
  echo "	-o  The output directory"
  exit -1
fi

while getopts ":b:r:m:o:" opt; do
  case $opt in
    b) REGIONS="$OPTARG"
    ;;
    r) REF="$OPTARG"
    ;;
    m) MOTIFS="$OPTARG"
    ;;
    o) OUTDIR="$OPTARG"
    ;; 
    \?) echo "Invalid option -$OPTARG" >&2
echo "	Usage:"
echo "	-b  A 4-column BED file where 4th column is the group assignment"
echo "	-r  The reference group. Should be one of the available groups or set to 'rest' to compare against the rest of the groups"
echo "	-m  The motif scans file"
echo "	-o  The output directory"
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if ! command -v tabix &> /dev/null
then
    echo "tabix could not be found. Make sure htsilb is installed and tabix is in your path."
    exit 1
fi

if ! command -v bedmap &> /dev/null
then
    echo "bedmap could not be found. Make sure bedops is installed and is in your path."
    exit 1
fi


TEMPDIR=$OUTDIR/"tmp"

SCRIPT=$(realpath "${0}")
SCRIPTPATH=$(dirname "${SCRIPT}")
SCRIPTPARENT=$(dirname "${SCRIPTPATH}")

echo ${SCRIPT}
echo ${SCRIPTPATH}
echo ${SCRIPTPARENT}

#REGIONS=$1
#REF=$2
#MOTIFS=$3
#OUTFILE=$4

if [[ ! -f "${REGIONS}" ]]; then
    echo "Regions BED file not found."
exit 1
fi

if [[ ! -f "${MOTIFS}" ]]; then
    echo "Motif scans file not found."
exit 1
fi

if [[ ! -d "${OUTDIR}" ]]; then
mkdir -p "${OUTDIR}"
fi

mkdir -p "${TEMPDIR}"

NF=`awk '{print NF; exit}' $REGIONS`

if (("$NF" < "4")); then
	echo "A BED file with 4 columns is required" 1>&2

	exit 1
fi

NROW=$(wc -l "${REGIONS}" | cut -d ' ' -f 1)
echo "$NROW regions detected"
cut -f 4 $REGIONS \
| sort \
| uniq -c

if [ "$REF" == "rest" ];
then
	echo $(date +"%Y-%m-%d %T %Z") 'Testing enchrichment against' $REF
else
	if grep -Rq $REF $REGIONS;
	then
		echo $(date +"%Y-%m-%d %T %Z") 'Testing enchrichment against' $REF
	else
		echo 'Please select one of:' $(cut -f 4 $REGIONS \
    | sort \
    | uniq \
    | tr '\n' '\ ') 1>&2
		exit 1
	fi
fi

awk -F'\t' '{print $1 FS $2 FS $3 FS "region"FNR FS $4;}' $REGIONS \
| sort-bed - > $TEMPDIR/regions.bed

echo $(date +"%Y-%m-%d %T %Z") "Mapping motifs to query"

cut -f 1-3 $REGIONS \
| sort-bed - \
| tabix -R - $MOTIFS \
| sort-bed - > $TEMPDIR/motifs_mapped_to_query.txt
#tabix -R $TEMPDIR/regions.bed $MOTIFS | sort-bed - > $TEMPDIR/motifs_mapped_to_query.txt

echo $(date +"%Y-%m-%d %T %Z") "Assigning DHS index to mapped motifs"

cut -f 1-4 $TEMPDIR/motifs_mapped_to_query.txt \
| bedmap --ec --echo --echo-map-id --skip-unmapped --delim '\t' - $TEMPDIR/regions.bed > $TEMPDIR/motifs_to_region_index.txt

RINPUT=$TEMPDIR/motifs_to_region_index.txt

Rscript "${SCRIPTPATH}"/hyperMotif.R ${OUTDIR} ${REF}

#rm -r $TEMPDIR

