#!/bin/bash

set -eo pipefail

## VIASH START
## VIASH END

# unset flags
[[ "$par_d" == "false" ]] && unset par_d

# run agat_sp_statistics
agat_sp_statistics.pl \
  -i "$par_gff" \
  -o "$par_output" \
  ${par_plot:+-d} \
  ${par_gs:+--gs "${par_gs}"} \
  ${par_verbose:+--verbose "${par_verbose}"} \
  ${par_config:+--config "${par_config}"}


