#!/bin/bash

source ../paramparser.sh

optAddPos  'output_file' 'Tabular file with first column is an id' 
optAddFlag  'enable_syslog'  'Path to input file'


# Parse users argument.
optParse $@

# Display user value
echo 'p1 :' $output_file
echo 'p2 :' $enable_syslog

