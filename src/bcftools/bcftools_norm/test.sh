#!/bin/bash

## VIASH START
## VIASH END

# Exit on error
set -eo pipefail

#test_data="$meta_resources_dir/test_data"

#############################################
# helper functions
assert_file_exists() {
  [ -f "$1" ] || { echo "File '$1' does not exist" && exit 1; }
}
assert_file_not_empty() {
  [ -s "$1" ] || { echo "File '$1' is empty but shouldn't be" && exit 1; }
}
assert_file_contains() {
  grep -q "$2" "$1" || { echo "File '$1' does not contain '$2'" && exit 1; }
}
assert_identical_content() {
  diff -a "$2" "$1" \
    || (echo "Files are not identical!" && exit 1)
}
#############################################

# Create directories for tests
echo "Creating Test Data..."
TMPDIR=$(mktemp -d "$meta_temp_dir/XXXXXX")
function clean_up {
  [[ -d "$TMPDIR" ]] && rm -r "$TMPDIR"
}
trap clean_up EXIT

# Create test data
cat <<EOF > "$TMPDIR/example.vcf"
##fileformat=VCFv4.1
##contig=<ID=1,length=249250621,assembly=b37>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	SAMPLE1
1	752567	llama	G	C,A	.	.	.	.	1/2
1	752722	.	G	A,AAA	.	.	.	.	./.
EOF

bgzip -c $TMPDIR/example.vcf > $TMPDIR/example.vcf.gz
tabix -p vcf $TMPDIR/example.vcf.gz

cat <<EOF > "$TMPDIR/reference.fa"
>1
ATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCG
>2
CGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGAT
EOF

# Test 1: Remove ID annotations
mkdir "$TMPDIR/test1" && pushd "$TMPDIR/test1" > /dev/null

echo "> Run bcftools_norm"
"$meta_executable" \
  --input "../example.vcf" \
  --output "normalized.vcf" \
  --atomize \
  --atom_overlaps "." \

# checks
assert_file_exists "normalized.vcf"
assert_file_not_empty "normalized.vcf"
assert_file_contains "normalized.vcf" "bcftools_normCommand=norm --atomize --atom-overlaps . -o normalized.vcf ../example.vcf"
echo "- test1 succeeded -"

popd > /dev/null

# Test 2: Check reference
mkdir "$TMPDIR/test2" && pushd "$TMPDIR/test2" > /dev/null

echo "> Run bcftools_norm with remove duplicates"
"$meta_executable" \
  --input "../example.vcf" \
  --output "normalized.vcf" \
  --atomize \
  --remove_duplicates 'all' \

# checks
assert_file_exists "normalized.vcf"
assert_file_not_empty "normalized.vcf"
assert_file_contains "normalized.vcf" "norm --atomize -d all -o normalized.vcf ../example.vcf"
echo "- test2 succeeded -"

popd > /dev/null

# Test 3: Check reference and fasta reference
mkdir "$TMPDIR/test3" && pushd "$TMPDIR/test3" > /dev/null

echo "> Run bcftools_norm with check reference and fasta reference"
"$meta_executable" \
  --input "../example.vcf" \
  --output "normalized.vcf" \
  --atomize \
  --fasta_ref "../reference.fa" \
  --check_ref "e" \

# checks
assert_file_exists "normalized.vcf"
assert_file_not_empty "normalized.vcf"
assert_file_contains "normalized.vcf" "norm --atomize -c e -f ../reference.fa -o normalized.vcf ../example.vcf"
echo "- test3 succeeded -"

popd > /dev/null

# Test 4: Multiallelics
mkdir "$TMPDIR/test4" && pushd "$TMPDIR/test4" > /dev/null

echo "> Run bcftools_norm with multiallelics"
"$meta_executable" \
  --input "../example.vcf" \
  --output "normalized.vcf" \
  --multiallelics "-any" \
  --old_rec_tag "wazzaaa" \

# checks
assert_file_exists "normalized.vcf"
assert_file_not_empty "normalized.vcf"
assert_file_contains "normalized.vcf" "norm -m -any --old-rec-tag wazzaaa -o normalized.vcf ../example.vcf"
echo "- test4 succeeded -"

echo "---- All tests succeeded! ----"
exit 0

# echo
# cat "normalized.vcf"
# echo