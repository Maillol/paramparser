#!/bin/bash

declare -a OPTION_NAMES
declare -a OPTION_ARGS
declare -a OPTION_HELPS
declare -a OPTION_POSITIONALS_NAMES
declare -a OPTION_POSITIONALS_HELPS
declare -a OPTION_POSITIONALS_MULTIPLICITYS


#=== FUNCTION optAdd =========================================================
# USAGE: optAdd opt_name opt_args opt_help opt_defaut
# DESCRIPTION: add option to parseur.
#             
# PARAMETERS:
#    opt_name - Name of option without '--' prefix
#    opt_args - Name of args
#    opt_help - in line help.
#    opt_defaut - default value must be false for flag
#=============================================================================
function optAdd {
    declare -ir i=${#OPTION_NAMES[@]}
    OPTION_NAMES[$i]=$1
    OPTION_ARGS[$i]=$2
    OPTION_HELPS[$i]=$3
    eval $1'='$4
}


#=== FUNCTION optAddFlag =====================================================
# USAGE: optAddFlag opt_name opt_help
# DESCRIPTION: add flag option to parseur. A flag option is true or false
#             
# PARAMETERS:
#    opt_name - Name of option without '--' prefix
#    opt_help - in line help.
#=============================================================================
function optAddFlag {
    declare -ir i=${#OPTION_NAMES[@]}
    OPTION_NAMES[$i]=$1
    OPTION_ARGS[$i]=''
    OPTION_HELPS[$i]=$2
    eval $1'='false
}

#=== FUNCTION optAddPos ======================================================
# USAGE: optAddPos opt_name opt_help [multiplicity]
# DESCRIPTION: Add a positional argument to parser.
#
# PARAMETERS:
#    opt_name - Name of option without '--' prefix
#    opt_help - Inline help.
#    multiplicity - Must be '1', '+' or '*'. Default is '1'. Only the last
#                   argument can have '+' multiplicity. 
#=============================================================================
function optAddPos {
    declare -ir i=${#OPTION_POSITIONALS_NAMES[@]}
    OPTION_POSITIONALS_NAMES[$i]=$1
    OPTION_POSITIONALS_HELPS[$i]=$2
    if [[ $# == 3 ]]; then
        OPTION_POSITIONALS_MULTIPLICITYS[$i]=$3 
    else
        OPTION_POSITIONALS_MULTIPLICITYS[$i]='1'
    fi
}

#=== FUNCTION optUsage =======================================================
# USAGE: optUsage
# DESCRIPTION: Display Usage regarding optAdd call
#=============================================================================
function optUsage {
    declare -i i ;
    declare usage="["

    for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
        usage="$usage --${OPTION_NAMES[$i]}"
    done
    usage="$usage ] "

    for (( i = 0; i < ${#OPTION_POSITIONALS_NAMES[@]}; i++ )); do
        if [[ "${OPTION_POSITIONALS_MULTIPLICITYS[ $i ]}" == "1" ]]; then
            usage="$usage ${OPTION_POSITIONALS_NAMES[$i]}"
        else 
            if [[ "${OPTION_POSITIONALS_MULTIPLICITYS[ $i ]}" == "+" ]]; then
                usage="$usage ${OPTION_POSITIONALS_NAMES[$i]} [${OPTION_POSITIONALS_NAMES[$i]}]..."
            else
                if [[ "${OPTION_POSITIONALS_MULTIPLICITYS[ $i ]}" == "*" ]]; then
                    usage="$usage [${OPTION_POSITIONALS_NAMES[$i]}]..."
                fi
            fi
        fi
    done


    echo 'USAGE'
    echo -e '\t'$usage
    echo -e '\n'

    if [[ "${#OPTION_POSITIONALS_NAMES[@]}" > 0 ]]; then
        echo 'POSITIONALS ARGUMENTS'
        for (( i = 0; i < ${#OPTION_POSITIONALS_NAMES[@]}; i++ )); do
           echo -e '\t'${OPTION_POSITIONALS_NAMES[$i]}
           echo -e '\t\t'${OPTION_POSITIONALS_HELPS[$i]}
           echo -e '\n'
        done
    fi
    
    if [[ "${#OPTION_NAMES[@]}" > 0 ]]; then
        echo 'OPTION'
        for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
            echo -e '\t--'${OPTION_NAMES[$i]}' '${OPTION_ARGS[$i]}
            echo -e '\t\t'${OPTION_HELPS[$i]}
            echo -e '\n'
        done
    fi
    echo -e '\t-h --help'
    echo -e '\t\tDisplay this help and exit.'  
}

#=== FUNCTION _optSearch =====================================================
# USAGE: _optSearch option
# DESCRIPTION: search option in OPTION_NAMES array return 1 if element isn't
#              found
#              if a=$( _optSearch $1 ) ; then
#                  echo ${OPTION_HELPS[$a]};
#              fi
#             
# PARAMETERS:
#    option - option with -- prefix
#=============================================================================
function _optSearch {
    declare i ;
    for i in ${!OPTION_NAMES[@]} ;do
        if [[ --${OPTION_NAMES[$i]} = "$1" ]]; then
            echo $i
            return 0
        fi
    done
    return 1
}


function optParse {
    declare -i opt_i ;
    declare -i i=0 ;
    declare -i pos_args_i=0 ;
    declare -i nb_pos_args_given=0 ;
    declare pos_args=''
    declare var_name ;

    for (( i = 1; i <= ${#}; i++ )); do
        if [[ "${!i}" == "--help" || "${!i}" == "-h" ]]; then
            optUsage
            exit 0
        else 
            if opt_i=$( _optSearch ${!i} ) ; then
                var_name=${OPTION_NAMES[$opt_i]}
                if [ -z ${OPTION_ARGS[$opt_i]} ]; then
                    eval $var_name'=true'     
                else
                    (( ++i ))
                    eval $var_name'='${!i}  
                fi
            else
                var_name=${OPTION_POSITIONALS_NAMES[ $pos_args_i ]}
                if [[ "${OPTION_POSITIONALS_MULTIPLICITYS[ $pos_args_i ]}" == "1" ]]; then
                    eval $var_name'='${!i} 
                    ((++pos_args_i))    
                else
                    pos_args="$pos_args '"${!i}"'"
                fi
                ((++nb_pos_args_given))
            fi
        fi
    done

    # Test number of positionals arguments given.
    if [[ ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} > 0 ]]; then
        declare -i last_indice=$((${#OPTION_POSITIONALS_MULTIPLICITYS[@]} - 1))
        declare last_multiplicity="${OPTION_POSITIONALS_MULTIPLICITYS[ $last_indice ]}"
        var_name="${OPTION_POSITIONALS_NAMES[ $last_indice ]}"

        if [[ "$last_multiplicity" == "+" ]]; then
            if [[ $nb_pos_args_given < ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} ]]; then
                echo 'error: Too few arguments'
                echo "try '$0 --help' for more explanation"
                exit 1   
            fi
            eval "$var_name=( $pos_args )"

        else 
            if [[ "$last_multiplicity" == "*" ]]; then
                    if [[ $nb_pos_args_given < $(( ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} - 1 )) ]]; then
                        echo 'error: Too few arguments'
                        echo "try '$0 --help' for more explanation"
                        exit 1   
                    fi
                    eval "$var_name=( $pos_args )"

            else 
                    if [[ "$last_multiplicity" == "1" ]]; then
                        if [[ $nb_pos_args_given != ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} ]]; then
                            echo 'error: Wrong number of arguments'
                            echo "try '$0 --help' for more explanation"
                            exit 1   
                        fi
                    fi
           fi
        fi
    fi
}


