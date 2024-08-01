#!/bin/bash

TMP_DIR=/tmp/bd_rhapsody_make_reference
OUT_DIR=src/bd_rhapsody/test_data

# check if seqkit is installed
if ! command -v seqkit &> /dev/null; then
  echo "seqkit could not be found"
  exit 1
fi

# create temporary directory and clean up on exit
mkdir -p $TMP_DIR
function clean_up {
    rm -rf "$TMP_DIR"
}
trap clean_up EXIT

# fetch reference
ORIG_FA=$TMP_DIR/reference.fa.gz
if [ ! -f $ORIG_FA ]; then
  wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/GRCh38.primary_assembly.genome.fa.gz \
    -O $ORIG_FA
fi

ORIG_GTF=$TMP_DIR/reference.gtf.gz
if [ ! -f $ORIG_GTF ]; then
  wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz \
    -O $ORIG_GTF
fi

# create small reference
START=30000
END=31500
CHR=chr1

# subset to small region
seqkit grep -r -p "^$CHR\$" "$ORIG_FA" | \
  seqkit subseq -r "$START:$END" > $OUT_DIR/reference_small.fa

zcat "$ORIG_GTF" | \
  awk -v FS='\t' -v OFS='\t' "
    \$1 == \"$CHR\" && \$4 >= $START && \$5 <= $END {
      \$4 = \$4 - $START + 1;
      \$5 = \$5 - $START + 1;
      print;
    }" > $OUT_DIR/reference_small.gtf

# download bdabseq immunediscoverypanel fasta
# note: was contained in http://bd-rhapsody-public.s3.amazonaws.com/Rhapsody-Demo-Data-Inputs/12WTA-ABC-SMK-EB-5kJRT.tar
cat > $OUT_DIR/BDAbSeq_ImmuneDiscoveryPanel.fasta <<EOF
>CD11c:B-LY6|ITGAX|AHS0056|pAbO Catalog_940024
ATGCGTTGCGAGAGATATGCGTAGGTTGCTGATTGG
>CD14:MPHIP9|CD14|AHS0037|pAbO Catalog_940005
TGGCCCGTGGTAGCGCAATGTGAGATCGTAATAAGT
>CXCR5|CXCR5|AHS0039|pAbO Catalog_940042
AGGAAGGTCGATTGTATAACGCGGCATTGTAACGGC
>CD19:SJ25C1|CD19|AHS0030|pAbO Catalog_940004
TAGTAATGTGTTCGTAGCCGGTAATAATCTTCGTGG
>CD25:2A3|IL2RA|AHS0026|pAbO Catalog_940009
AGTTGTATGGGTTAGCCGAGAGTAGTGCGTATGATT
>CD27:M-T271|CD27|AHS0025|pAbO Catalog_940018
TGTCCGGTTTAGCGAATTGGGTTGAGTCACGTAGGT
>CD278|ICOS|AHS0012|pAbO Catalog_940043
ATAGTCCGCCGTAATCGTTGTGTCGCTGAAAGGGTT
>CD279:EH12-1|PDCD1|AHS0014|pAbO Catalog_940015
ATGGTAGTATCACGACGTAGTAGGGTAATTGGCAGT
>CD3:UCHT1|CD3E|AHS0231|pAbO Catalog_940307
AGCTAGGTGTTATCGGCAAGTTGTACGGTGAAGTCG
>GITR|TNFRSF18|AHS0104|pAbO Catalog_940096
TCTGTGTGTCGGGTTGAATCGTAGTGAGTTAGCGTG
>Tim3|HAVCR2|AHS0016|pAbO Catalog_940066
TAGGTAGTAGTCCCGTATATCCGATCCGTGTTGTTT
>CD4:SK3|CD4|AHS0032|pAbO Catalog_940001
TCGGTGTTATGAGTAGGTCGTCGTGCGGTTTGATGT
>CD45RA:HI100|PTPRC|AHS0009|pAbO Catalog_940011
AAGCGATTGCGAAGGGTTAGTCAGTACGTTATGTTG
>CD56:NCAM16.2|NCAM1|AHS0019|pAbO Catalog_940007
AGAGGTTGAGTCGTAATAATAATCGGAAGGCGTTGG
>CD62L:DREG-56|SELL|AHS0049|pAbO Catalog_940041
ATGGTAAATATGGGCGAATGCGGGTTGTGCTAAAGT
>CCR7|CCR7|AHS0273|pAbO Catalog_940394
AATGTGTGATCGGCAAAGGGTTCTCGGGTTAATATG
>CXCR6|CXCR6|AHS0148|pAbO Catalog_940234
GTGGTTGGTTATTCGGACGGTTCTATTGTGAGCGCT
>CD127|IL7R|AHS0028|pAbO Catalog_940012
AGTTATTAGGCTCGTAGGTATGTTTAGGTTATCGCG
>CD134:ACT35|TNFRSF4|AHS0013|pAbO Catalog_940060
GGTGTTGGTAAGACGGACGGAGTAGATATTCGAGGT
>CD28:L293|CD28|AHS0138|pAbO Catalog_940226
TTGTTGAGGATACGATGAAGCGGTTTAAGGGTGTGG
>CD272|BTLA|AHS0052|pAbO Catalog_940105
GTAGGTTGATAGTCGGCGATAGTGCGGTTGAAAGCT
>CD8:SK1|CD8A|AHS0228|pAbO Catalog_940305
AGGACATAGAGTAGGACGAGGTAGGCTTAAATTGCT
>HLA-DR|CD74|AHS0035|pAbO Catalog_940010
TGTTGGTTATTCGTTAGTGCATCCGTTTGGGCGTGG
>CD16:3G8|FCGR3A|AHS0053|pAbO Catalog_940006
TAAATCTAATCGCGGTAACATAACGGTGGGTAAGGT
>CD183|CXCR3|AHS0031|pAbO Catalog_940030
AAAGTGTTGGCGTTATGTGTTCGTTAGCGGTGTGGG
>CD196|CCR6|AHS0034|pAbO Catalog_940033
ACGTGTTATGGTGTTGTTCGAATTGTGGTAGTCAGT
>CD137|TNFRSF9|AHS0003|pAbO Catalog_940055
TGACAAGCAACGAGCGATACGAAAGGCGAAATTAGT
>CD161:HP-3G10|KLRB1|AHS0205|pAbO Catalog_940283
TTTAGGACGATTAGTTGTGCGGCATAGGAGGTGTTC
>IgM|IGHM|AHS0198|pAbO Catalog_940276
TTTGGAGGGTAGCTAGTTGCAGTTCGTGGTCGTTTC
>IgD|IGHD|AHS0058|pAbO Catalog_940026
TGAGGGATGTATAGCGAGAATTGCGACCGTAGACTT
EOF
