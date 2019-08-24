Paramparser
===========

The best way to parse command line arguments in BASH

Use paramparser to write a command-line interfaces. You only define optional and requiered arguments and 
paramparser will store parsed argument value in the generated bash variable. 
paramparser also generates help and error message when the users provide a wrong command.


How to Install paramparser
==========================

System installation
-------------------

```
sudo mkdir -p /usr/lib/bash
sudo curl https://raw.githubusercontent.com/Maillol/paramparser/master/paramparser.sh  --output /usr/lib/bash/paramparser.sh
```

User installation
-----------------

```
mkdir -p ~/.local/lib/bash
curl https://raw.githubusercontent.com/Maillol/paramparser/master/paramparser.sh  --output ~/.local/lib/bash/paramparser.sh
```

Example using paramparser :-D
=============================
```bash
source paramparser.sh

optAdd  'config' 'CONFIG_FILE' 'Input config file' '?' ':NO_CONFIG:'
optAdd  'col' 'NUM_COLUMN' 'Display this column'   '*'
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'
optAddPos 'output_file'  'Tabular file with first column is an id'
optAddPos 'input_file' 'Path to output file'  '+'

optParse "$@"

# paramparser will generate bash variable containing the parsing parameters for you.
echo 'config:' $config
echo 'col:' ${col[@]}
echo 'verbose:' $verbose
echo 'output_file:' $output_file
echo 'input_file:' "${input_file[@]}"
```


Tutorial
========

## 1. paramparser.sh is included.

```bash
source paramparser.sh
```

## 2. Optionals and positionals arguments are defined.

```bash
# Add optionals arguments, inline help and cardinality.
# Use optAdd to add option.
# optAdd take 5 parameters:
#   1 - The name of bash variable to create
#   2 - The name of parameter to display in the help
#   3 - The inline help to display
#   4 - The command-line parameters can be present ('?' one or zero) ('*' zero or several) time
#   5 - The default value to store in the variable to create.

optAdd  'config' 'CONFIG_FILE' 'Input config file' '?' ':NO_CONFIG:'

# optAddFlag is like optAdd but the stored value in the created variable will be true or false.
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'

# Add positionals arguments
optAddPos 'output_file'  'Tabular file with first column is an id'
optAddPos 'input_file' 'Path to input files'  '+'  # '+' means one or multiple input files
```

## 3. User parameters are parsed.

```bash
# Use optParse function to parse users arguments.
optParse "$@"

# OptParse has initialised variables specified with optAdd, optAddFlag or optAddPos functions.
echo 'config :' $config
echo 'verbose :' $verbose
echo 'positional argument 1 :' $output_file
echo 'last positionals arguments  :' "${input_file[@]}"
```

## 4. It is done ! Try your program :-)

```
$ ./example.sh  -h
USAGE
	example.sh [--config] [--verbose] output_file input_file [input_file]...


POSITIONALS ARGUMENTS
	output_file
		Tabular file with first column is an id


	input_file
		Path to output file


OPTIONS
	--config CONFIG_FILE
		Input config file


	--verbose
		Displays more descriptive information than the default output.


	-h --help
		Display this help and exit.
```

```
$ ./example.sh  --config my_config  foo  bar1 bar2
config : my_config
verbose : false
positional argument 1 : foo
last positionals arguments  : bar1 bar2
```


Example with Sub-commands
=========================

```
#!/bin/bash

source paramparser.sh

optAddCommand prepare 'Use this command to prepare a drink'
optAddCommand serve-drink-in-the-right-way 'Use this command to serve a drink' 'serve'


function prepare {
    optAddCommand prepare-tea 'Prepare a tea' 'tea'
    optAddCommand prepare-coffe 'Prepare a coffe' 'coffe'
    optParse $@
}


function prepare-coffe {
    optAddFlag 'cold' 'Create a cold coffe'
    optParse $@

    echo 'cold :' $cold
}


function prepare-tea {
    optAdd 'color' 'COLOR' 'red, yellow, green or black' '?' 'green'
    optParse $@

    echo 'color :' $color
}


function serve-drink-in-the-right-way {
    optAddPos 'customer' 'The name of the customer' '+'
    optParse $@

    echo 'customer :' ${customer[@]}
}


optParse $@
```

How provide paramparser in the script using paramparser
=======================================================


```
if [[ -f ~/.local/lib/bash/paramparser.sh ]]; then
    source ~/.local/lib/bash/paramparser.sh
elif [[ -f /usr/lib/bash/paramparser.sh ]]; then
    source /usr/lib/bash/paramparser.sh
else
    mkdir -p ~/.local/lib/bash
    curl https://raw.githubusercontent.com/Maillol/paramparser/master/paramparser.sh  --output ~/.sources/paramparser.sh
    source ~/.sources/paramparser.sh
fi
```


Documentation
=============

You can read the generated documentation executing paramparser.sh

```
bash paramparser.sh
```
