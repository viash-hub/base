# salmon quant test data

# Test data was obtained from https://github.com/snakemake/snakemake-wrappers/tree/master/bio/salmon/quant/test

if [ ! -d /tmp/snakemake-wrappers ]; then
  git clone --depth 1 --single-branch --branch master https://github.com/snakemake/snakemake-wrappers /tmp/snakemake-wrappers
fi

cp -r /tmp/snakemake-wrappers/bio/salmon/quant/test/* src/salmon/quant/test_data

# Subset fastq files to 1000 reads
# Example: 
seqtk sample -s100 a_se.fq.gz 1000 > a_se.fq