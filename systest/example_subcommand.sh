#!/bin/bash

source ../paramparser.sh

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
