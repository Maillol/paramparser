#!/bin/bash

# Try this programm:
# $ ./exemple.sh 
# $ ./exemple.sh --help
# $ ./exemple.sh --verbose --config toto
# $ ./exemple.sh --config toto my_out_file.txt my_in_file.tab

# You can use options and positionals arguments anywhere.
# $ ./exemple.sh my_out_file.txt my_in_file.tab --config toto  my_other_in_file 

source paramparser.sh


## Exemple:
## Create your arguments:
optAdd  'config' 'CONFIG_FILE' 'Input config file' ''               # Add an option which requires an argument. This line create 'config' variable.
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'  # Add a flag option. This line create boolean 'verbose' variable.
optAddPos 'output_file'  'Tabular file with first column is an id'   # Add a positional argument.
optAddPos 'input_file' 'Path to output file'  '+'                    # Add an other positional argument '+' means create 'output_file' array and store the last positionals arguments.

# Use optParse function to parse users argument.
optParse $@

# Display user value
echo 'config :' $config
echo 'verbose :' $verbose
echo 'positional argument 1 :' $output_file
echo 'last positionals arguments  :' "${input_file[@]}"

