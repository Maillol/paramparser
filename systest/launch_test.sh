#!/bin/bash

function test_or_exit {
    cmp $1 $2 1> /dev/null 2> /dev/null
    if [[ $? != 0 ]]; then
        echo  cmp $1 $2 ' .............. [FAIL]'
        echo '-------------------- EXPECTED --------------------'
        cat $1
        echo '-------------------- RETURNED --------------------'
        cat $2
        exit 1
    else
        echo cmp $1 $2 ' .............. [pass]'
        rm $2
    fi
}

# Test multiplicity '1'
./example_1.sh toto > returned
test_or_exit example_1-1or3.expected returned

./example_1.sh toto tata titi > returned
test_or_exit example_1-1or3.expected returned

./example_1.sh toto tata > returned
test_or_exit example_1-2.expected returned

# Test multiplicity '+'
./example_plus.sh toto > returned
test_or_exit example_plus-1.expected returned

./example_plus.sh toto tata > returned
test_or_exit example_plus-2.expected returned

./example_plus.sh toto tata titi > returned
test_or_exit example_plus-3.expected returned

# Test multiplicity '*'
./example_star.sh > returned
test_or_exit example_star-0.expected returned

./example_star.sh toto > returned
test_or_exit example_star-1.expected returned

./example_star.sh toto tata > returned
test_or_exit example_star-2.expected returned

./example_star.sh toto tata titi > returned
test_or_exit example_star-3.expected returned

# Test flag
./example_flag.sh toto --enable-syslog > returned
test_or_exit example_flag-1.expected returned

./example_flag.sh toto > returned
test_or_exit example_flag-2.expected returned

# Test option with  multiplicity '?'
./example_option.sh > returned
test_or_exit example_option-1.expected returned

# Test option with  multiplicity '*'
./example_option.sh --output-format xml --output-filter YYY  --output-filter XXX > returned
test_or_exit example_option-2.expected returned

# Test sub command
./example_subcommand.sh > returned
test_or_exit example_subcommand-1.expected returned

./example_subcommand.sh prepare --help > returned
test_or_exit example_subcommand-2.expected returned

./example_subcommand.sh prepare tea --help > returned
test_or_exit example_subcommand-3.expected returned

./example_subcommand.sh prepare coffe --help > returned
test_or_exit example_subcommand-4.expected returned

./example_subcommand.sh serve --help > returned
test_or_exit example_subcommand-5.expected returned

./example_subcommand.sh prepare coffe --cold > returned
test_or_exit example_subcommand-6.expected returned

./example_subcommand.sh prepare coffe > returned
test_or_exit example_subcommand-7.expected returned




