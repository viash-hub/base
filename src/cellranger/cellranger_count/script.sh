#!/bin/bash

set -eo pipefail

## VIASH START
par_input='/opt/cellranger-8.0.0/lib/python/cellranger-tiny-fastq'
par_reference='/opt/cellranger-8.0.0/lib/python/cellranger-tiny-ref'
par_output='test_data/bam'
par_chemistry="auto"
par_expect_cells="3000"
par_secondary_analysis="false"
## VIASH END

# just to make sure paths are absolute
par_reference=$(realpath $par_reference)
par_output=$(realpath $par_output)

# create temporary directory
tmpdir=$(mktemp -d "$meta_temp_dir/$meta_name-XXXXXXXX")
function clean_up {
    rm -rf "$tmpdir"
}
trap clean_up EXIT

echo "test 1"

# process inputs
# for every fastq file found, make a symlink into the tempdir
fastq_dir="$tmpdir/fastqs"
mkdir -p "$fastq_dir"
IFS=";"
for var in $par_input; do
  unset IFS
  abs_path=$(realpath $var)
  if [ -d "$abs_path" ]; then
    find "$abs_path" -name *.fastq.gz -exec ln -s {} "$fastq_dir" \;
  else
    ln -s "$abs_path" "$fastq_dir"
  fi
done

echo "test 2"
echo "fastq_dir: $fastq_dir"
echo "contents: $(ls $fastq_dir)"

# process reference
if file $par_reference | grep -q 'gzip compressed data'; then
  echo "Untarring genome"
  reference_dir="$tmpdir/fastqs"
  mkdir -p "$reference_dir"
  tar -xvf "$par_reference" -C "$reference_dir"
  par_reference="$reference_dir"
fi

echo "test 3"

# cd into tempdir
cd "$tmpdir"

no_secondary_analysis=""
if [ "$par_secondary_analysis" == "false" ]; then
  no_secondary_analysis="true"
fi

echo "test 4" 

IFS=","
id=myoutput
cellranger count \
  --id="$id" \
  --fastqs="$fastq_dir" \
  --transcriptome="$par_reference" \
  --include-introns="$par_include_introns" \
  ${meta_cpus:+--localcores=$meta_cpus} \
  ${meta_memory_gb:+--localmem=$((meta_memory_gb-2))} \
  ${par_expect_cells:+--expect-cells=$par_expect_cells} \
  ${par_force_cells:+--force-cells=$par_force_cells} \
  ${par_chemistry:+--chemistry="$par_chemistry"} \
  ${par_generate_bam:+--create-bam=$par_generate_bam} \
  ${no_secondary_analysis:+--nosecondary} \
  ${par_r1_length:+--r1-length=$par_r1_length} \
  ${par_r2_length:+--r2-length=$par_r2_length} \
  ${par_lanes:+--lanes=${par_lanes[*]}} \
  ${par_library_compatibility_check:+--check-library-compatibility=$par_library_compatibility_check}\
  --disable-ui
unset IFS

echo "test 5"

echo "Copying output"
if [ -d "$id/outs/" ]; then
  if [ ! -d "$par_output" ]; then
    mkdir -p "$par_output"
  fi
  cp -r "$id/outs/"* "$par_output"
  rm -rf "$id"
fi
