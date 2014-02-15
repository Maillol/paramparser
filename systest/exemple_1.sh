#!/bin/bash


source ../paramparser.sh

optAddPos  'output_file' 'Tabular file with first column is an id' 
optAddPos  'input_file'  'Path to output file'

# Parse users argument.
optParse $@

# Display user value
echo 'p1 :' $output_file
echo 'p2 :' $input_file

