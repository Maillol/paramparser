Paramparser
===========

Arguments parser for bash

Exemple
=======

## 1. Include paramparser.sh

```bash
source paramparser.sh  
```

## 2. Adding optionals arguments and positionals arguments

```bash
# Add optionals arguments.
optAdd  'config' 'CONFIG_FILE' 'Input config file' ''
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'  

# Add positionals arguments.
optAddPos 'output_file'  'Tabular file with first column is an id'
optAddPos 'input_file' 'Path to output file'  '+'                    
```

## 3. Getting user parameters

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
$ ./exemple.sh  -h
USAGE
	[ --config --verbose ] output_file input_file [input_file]...


POSITIONALS ARGUMENTS
	output_file
		Tabular file with first column is an id


	input_file
		Path to output file


OPTION
	--config CONFIG_FILE
		Input config file


	--verbose 
		Displays more descriptive information than the default output.


	-h --help
		Display this help and exit.
```
```
$ ./exemple.sh  --config my_config  foo  bar1 bar2
config : my_config
verbose : false
positional argument 1 : foo
last positionals arguments  : bar1 bar2
```
