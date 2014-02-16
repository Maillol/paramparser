paramparser
===========

Arguments parser for bash

Exemple
=======

source paramparser.sh  # Include paramparser.

# Adding optionals arguments:
optAdd  'config' 'CONFIG_FILE' 'Input config file' ''                # Add an option which requires an argument. This line create 'config' variable.
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'  # Add a flag option. This line create boolean 'verbose' variable.

# Adding positionals arguments
optAddPos 'output_file'  'Tabular file with first column is an id'   # Add a positional argument.
optAddPos 'input_file' 'Path to output file'  '+'                    # Add an other positional argument '+' means create 'output_file' array and store the last positionals arguments.

# Use optParse function to parse users argument.
optParse "$@"


# Getting user parameters
echo 'config :' $config
echo 'verbose :' $verbose
echo 'positional argument 1 :' $output_file
echo 'last positionals arguments  :' "${input_file[@]}"
