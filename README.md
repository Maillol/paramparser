Paramparser
===========

The best way to parse command line arguments in BASH


Without paramparser :-(
-----------------------
```bash
verbose=False
output_file=""
declare -a input_file
config=":NO_CONFIG:"
col='*'
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --config)
            if [[ -z "$2" ]]; then
                echo "Error config has not value" 
            fi
            config="$2"
            shift 2
            ;;

        --col)
            if [[ -z "$2" ]]; then
                echo "Error col has not value" 
            fi
            col="$2"
            shift 2
            ;;

        --verbose)
            verbose=True
            shift
            ;;
        --help)
            echo -e 'USAGE'
            echo -e '	[ --config --col --verbose ] output_file input_file [input_file]...\n\n'
            echo -e 'POSITIONALS ARGUMENTS'
            echo -e '	output_file'
            echo -e '		Tabular file with first column is an id\n\n'
            echo -e '	input_file'
            echo -e '		Path to output file\n\n'
            echo -e 'OPTION'
            echo -e '	--config CONFIG_FILE'
            echo -e '		Input config file\n\n'
            echo -e '	--col NUM_COLUMN'
            echo -e '		Display this column\n\n'
            echo -e '	--verbose '
            echo -e '		Displays more descriptive information than the default output.\n\n'
            echo -e '	-h --help'
            echo -e '		Display this help and exit.'
            exit
            ;;
        --*)
            # unknown option 
            ;;
        *) 
            if [[ -z "$output_file" ]]; then
                output_file="$1"
            else
                input_file[${#input_file[@]}]="$1"
            fi
            shift
    esac
done
```

With paramparser :-D
--------------------
```bash
source paramparser.sh

optAdd  'config' 'CONFIG_FILE' 'Input config file' '?' ':NO_CONFIG:'  
optAdd  'col' 'NUM_COLUMN' 'Display this column'   '*'
optAddFlag 'verbose' 'Displays more descriptive information than the default output.'
optAddPos 'output_file'  'Tabular file with first column is an id'
optAddPos 'input_file' 'Path to output file'  '+'

optParse "$@"
```


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
