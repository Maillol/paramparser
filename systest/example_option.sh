#!/bin/bash

source ../paramparser.sh
optAdd 'output_format' 'FORMAT' 'Define the output format (xml, json, yml) the default format is json' '?' 'json'
optAdd 'output_filter' 'NAME' 'Add a filter' '*'

# Parse users argument.
optParse $@

# Display user value
echo 'p1 :' $output_format
echo 'p2 :' "${output_filter[@]}"
