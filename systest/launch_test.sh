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
./exemple_1.sh toto > returned
test_or_exit exemple_1-1or3.expected returned

./exemple_1.sh toto tata titi > returned
test_or_exit exemple_1-1or3.expected returned

./exemple_1.sh toto tata > returned
test_or_exit exemple_1-2.expected returned

# Test multiplicity '+'
./exemple_plus.sh toto > returned
test_or_exit exemple_plus-1.expected returned

./exemple_plus.sh toto tata > returned
test_or_exit exemple_plus-2.expected returned

./exemple_plus.sh toto tata titi > returned
test_or_exit exemple_plus-3.expected returned

# Test multiplicity '*'
./exemple_star.sh > returned
test_or_exit exemple_star-0.expected returned

./exemple_star.sh toto > returned
test_or_exit exemple_star-1.expected returned

./exemple_star.sh toto tata > returned
test_or_exit exemple_star-2.expected returned

./exemple_star.sh toto tata titi > returned
test_or_exit exemple_star-3.expected returned

# Test flag
./exemple_flag.sh toto --enable-syslog > returned
test_or_exit exemple_flag-1.expected returned

./exemple_flag.sh toto > returned
test_or_exit exemple_flag-2.expected returned

# Test option with  multiplicity '?'
./exemple_option.sh > returned
test_or_exit exemple_option-1.expected returned

# Test option with  multiplicity '*'
./exemple_option.sh --output-format xml --output-filter YYY  --output-filter XXX > returned
test_or_exit exemple_option-2.expected returned


