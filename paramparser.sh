#!/bin/bash

declare -a OPTION_NAMES
declare -a OPTION_ARGS
declare -a OPTION_HELPS
declare -a OPTION_MULTIPLICITYS
declare -a OPTION_POSITIONALS_NAMES
declare -a OPTION_POSITIONALS_HELPS
declare -a OPTION_POSITIONALS_MULTIPLICITYS
declare -a OPTION_COMMAND_NAMES
declare -a OPTION_COMMAND_HELPS
declare -a OPTION_COMMAND_FUNCS
declare -a OPTION_CURRENT_COMMAND


#=== FUNCTION optAdd ==========================================================
# USAGE: optAdd name args help multiplicity [defaut]
# DESCRIPTION: add option to parseur.
#
# PARAMETERS:
#    name - Name of option without '--' prefix
#    args - Name of args displaying in generated help
#    help - in line help.
#    multiplicity - if multiplicity is '?' the <name> variable will be created
#                   if multiplicity is '*' the <name> array will be created
#                   and the commande line will contain several time this option.
#    defaut - default value of the variable <name> (ignored if multiplicity is
#             '*')
#==============================================================================
function optAdd {
    declare -ir i=${#OPTION_NAMES[@]}
    OPTION_NAMES[$i]=${1//_/-}
    OPTION_ARGS[$i]=$2
    OPTION_HELPS[$i]=$3
    if [[ "$4" != "?" && "$4" != "*" ]]; then
        echo -e "\e[1;31mParamparser Programming Error:\e[0m optAdd argument 4 expected '?' or '*'." 1>&2
        exit 1
    fi
    OPTION_MULTIPLICITYS[$i]=$4
    if [[ $# == 5 && $4 == '?' ]]; then
        eval $1"='"$5"'"
    else
        eval $1"=''"
    fi
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
    OPTION_NAMES[$i]=${1//_/-}
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
    declare -ir prev_i=$(($i - 1))

    if [[ "$prev_i" -ge "0" && ${OPTION_POSITIONALS_MULTIPLICITYS[$prev_i]} != '1' ]]; then
        echo -e "\e[1;31mParamparser Programming Error:\e[0m You can't add positional argument after an other with '*' or '+' multiplicity." 1>&2
        exit 1;
    fi

    if [[ $# == 3 ]]; then
        if [[ "$3" != "1" && "$3" != "+" && "$3" != "*"  ]]; then
            echo -e "\e[1;31mParamparser Programming Error:\e[0m optAddPos argument 3 expected '1', '*' or '+'." 1>&2
            exit 1;
        fi
        OPTION_POSITIONALS_MULTIPLICITYS[$i]=$3
    else
        OPTION_POSITIONALS_MULTIPLICITYS[$i]='1'
    fi
}

#=== FUNCTION optAddCommand ==================================================
# USAGE: optAddCommand function command_help [command_name]
# DESCRIPTION: Add a subcommand to parser.
#
# PARAMETERS:
#    function - The name of function to call
#    command_help - Inline help about the command
#    command_name - Use this option if you want a different name than the
#        function name
#=============================================================================
function optAddCommand {
    declare -ir i=${#OPTION_COMMAND_NAMES[@]}
    OPTION_COMMAND_FUNCS[$i]=$1
    OPTION_COMMAND_HELPS[$i]=$2
    OPTION_COMMAND_NAMES[$i]=${3-$1}
}


#=== FUNCTION optUsage =======================================================
# USAGE: optUsage
# DESCRIPTION: Display Usage regarding optAdd call
#=============================================================================
function optUsage {
    declare -i i ;
    declare usage="${0##*/} "

    for (( i = 0; i < ${#OPTION_CURRENT_COMMAND[@]}; i++ )); do
        usage="$usage ${OPTION_CURRENT_COMMAND[$i]} "
    done


    if [[ "${#OPTION_NAMES[@]}" -gt 0 ]]; then
        for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
            usage="$usage [--${OPTION_NAMES[$i]} ${OPTION_ARGS[$i]}]"
        done
    fi

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

    if [[ "${#OPTION_COMMAND_NAMES[@]}" -gt 0 ]]; then
        usage="$usage <command> "
    fi

    echo 'USAGE'
    echo -e '\t'$usage
    echo -e '\n'

    if [[ "${#OPTION_POSITIONALS_NAMES[@]}" -gt 0 ]]; then
        echo 'POSITIONALS ARGUMENTS'
        for (( i = 0; i < ${#OPTION_POSITIONALS_NAMES[@]}; i++ )); do
           echo -e '\t'${OPTION_POSITIONALS_NAMES[$i]}
           echo -e '\t\t'${OPTION_POSITIONALS_HELPS[$i]}
           echo -e '\n'
        done
    fi

    echo 'OPTIONS'
    if [[ "${#OPTION_NAMES[@]}" -gt 0 ]]; then
        for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
            echo -e '\t--'${OPTION_NAMES[$i]}' '${OPTION_ARGS[$i]}
            echo -e '\t\t'${OPTION_HELPS[$i]}
            echo -e '\n'
        done
    fi
    echo -e '\t-h --help'
    echo -e '\t\tDisplay this help and exit.'

    if [[ "${#OPTION_COMMAND_NAMES[@]}" -gt 0 ]]; then
        echo -e '\nCOMMANDS'
        for (( i = 0; i < (( ${#OPTION_COMMAND_NAMES[@]} - 1 )); i++ )); do
            echo -e '\t'${OPTION_COMMAND_NAMES[$i]}
            echo -e '\t\t'${OPTION_COMMAND_HELPS[$i]}
            echo -e '\n'
        done
        echo -e '\t'${OPTION_COMMAND_NAMES[$i]}
        echo -e '\t\t'${OPTION_COMMAND_HELPS[$i]}
    fi
}

#=== FUNCTION _optSearch =====================================================
# USAGE: _optSearch option
# DESCRIPTION: search option in OPTION_NAMES array and display the
#              indice. The exit status is 1 if the option isn't found
#              else 0
#
#              example:
#                  if a=$( _optSearch $1 ) ; then
#                      echo ${OPTION_HELPS[$a]};
#                  fi
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

#=== FUNCTION _optCommandSearch ==============================================
# USAGE: _optCommandSearch command_name
# DESCRIPTION: search option in OPTION_COMMAND_NAMES array and display the
#              indice. The exit status is 1 if the command_name isn't found
#              else 0
#
# PARAMETERS:
#    command - A command name
#=============================================================================
function _optCommandSearch {
    declare i ;
    for i in ${!OPTION_COMMAND_NAMES[@]} ;do
        if [[ ${OPTION_COMMAND_NAMES[$i]} = "$1" ]]; then
            echo $i
            return 0
        fi
    done
    return 1
}

#=== FUNCTION _optShowErrorAndExit ===========================================
# USAGE: _optShowErrorAndExit message
#
# PARAMETERS:
#    message - The message to display on the stderr
#=============================================================================
function _optShowErrorAndExit {
    echo 2>&1 "$1"
    echo 2>&1 "try '$0 --help' for more explanation"
    exit 1
}

#=== FUNCTION _optParseCommand ===============================================
# USAGE: _optParseCommand
#
# DESCRIPTION: Parse command if optAddCommand has been used reading
#              $@ variable
#=============================================================================
function _optParseCommand {
    declare -i i=0
    declare -i cmd_i=0
    declare command_func
    if [[ ${#OPTION_COMMAND_NAMES[@]} -gt 0 ]]; then
        if [[ ${#} -gt 0 ]]; then
            if [[ "${1}" == "--help" || "${1}" == "-h" ]]; then
                optUsage
                exit 0
            else
                if cmd_i=$( _optCommandSearch ${1} ) ; then
                    OPTION_CURRENT_COMMAND+=(${1})
                    command_func=${OPTION_COMMAND_FUNCS[$cmd_i]}
                    OPTION_COMMAND_NAMES=()
                    OPTION_COMMAND_FUNCS=()
                    shift
                    $command_func "${@}"
                    exit $?
                else
                    _optShowErrorAndExit "'${1}' is not a command (available commands: ${OPTION_COMMAND_NAMES[*]})"
                fi
            fi
        else
            optUsage
            exit 0
        fi
    fi
}

function optParse {
    declare -i opt_i ;
    declare -i i=0 ;
    declare -i pos_args_i=0 ;
    declare -i nb_pos_args_given=0 ;
    declare pos_args=''
    declare var_name ;
    declare -A opt_with_star_multiplicity

    _optParseCommand "${@}"

    for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
        if [[ ${OPTION_MULTIPLICITYS[$i]} == '*' ]]; then
            opt_with_star_multiplicity[ ${OPTION_NAMES[$i]} ]='( '
        fi
    done

    for (( i = 1; i <= ${#}; i++ )); do
        if [[ "${!i}" == "--help" || "${!i}" == "-h" ]]; then
            optUsage
            exit 0
        else
            if opt_i=$( _optSearch ${!i} ) ; then
                var_name=${OPTION_NAMES[$opt_i]}
                if [[ -z ${OPTION_ARGS[$opt_i]} ]]; then
                    eval ${var_name//-/_}'=true'
                else
                    (( ++i ))

                    if [[ ${i} -gt ${#} ]]; then
                        _optShowErrorAndExit "error: option --${var_name} needs a value"
                    fi

                    if [[ ${OPTION_MULTIPLICITYS[ $opt_i ]} == '?' ]]; then
                        eval ${var_name//-/_}"='"${!i}"'"
                    else
                        opt_with_star_multiplicity[ ${OPTION_NAMES[$opt_i]} ]=${opt_with_star_multiplicity[ ${OPTION_NAMES[$opt_i]} ]}"'"${!i}"' "
                    fi
                fi
            else
                var_name=${OPTION_POSITIONALS_NAMES[ $pos_args_i ]}
                if [[ "${OPTION_POSITIONALS_MULTIPLICITYS[ $pos_args_i ]}" == "1" ]]; then
                    eval $var_name"='"${!i}"'"
                    ((++pos_args_i))
                else
                    pos_args="$pos_args '"${!i}"'"
                fi
                ((++nb_pos_args_given))
            fi
        fi
    done

    # Eval array for option with * multiplicity
    for (( i = 0; i < ${#OPTION_NAMES[@]}; i++ )); do
        if [[ ${OPTION_MULTIPLICITYS[$i]} == '*' ]]; then
            var_name=${OPTION_NAMES[$i]}
            eval ${var_name//-/_}=${opt_with_star_multiplicity[ ${OPTION_NAMES[$i]} ]}')'
        fi
    done


    # Test number of positionals arguments given.
    if [[ ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} -gt 0 ]]; then
        declare -i last_indice=$((${#OPTION_POSITIONALS_MULTIPLICITYS[@]} - 1))
        declare last_multiplicity="${OPTION_POSITIONALS_MULTIPLICITYS[ $last_indice ]}"
        var_name="${OPTION_POSITIONALS_NAMES[ $last_indice ]}"

        if [[ "$last_multiplicity" == "+" ]]; then
            if [[ $nb_pos_args_given -lt ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} ]]; then
                _optShowErrorAndExit 'error: Too few arguments'
            fi
            eval "$var_name=( $pos_args )"

        else
            if [[ "$last_multiplicity" == "*" ]]; then
                    if [[ $nb_pos_args_given -lt $(( ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} - 1 )) ]]; then
                        _optShowErrorAndExit 'error: Too few arguments'
                    fi
                    eval "$var_name=( $pos_args )"

            else
                    if [[ "$last_multiplicity" == "1" ]]; then
                        if [[ $nb_pos_args_given != ${#OPTION_POSITIONALS_MULTIPLICITYS[@]} ]]; then
                            _optShowErrorAndExit 'error: Wrong number of arguments'
                        fi
                    fi
           fi
        fi
    elif [[ $nb_pos_args_given -gt 0 ]]; then
        _optShowErrorAndExit 'error: Wrong number of arguments'
    fi
}


if [[ "$0" =~ paramparser.sh$ ]]; then
    # Display publics functions (privates functions startswith by _).
    awk -v func_name="$1" 'BEGIN{ flag=0 }
         {
         if (substr($0,1,13) == "#=== FUNCTION" &&
             substr($0,15,1) != "_" )
            {
            if ( func_name == "" )
                {flag="1"}
            else if ( substr( $0, 15, length(func_name) ) &&
                      substr( $0, 15 + length(func_name), 1 ) == " " )
                {flag="1"}
            }
         else if (substr($0,1,5) == "#====" && flag == "1" )
             {flag=0;print$0"\n\n"};
         if ( flag == "1" )
            {print $0}
         }' $0
fi

