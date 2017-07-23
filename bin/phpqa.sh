#!/usr/bin/env bash

function displayError()
{
    local exitError=$1;
    printf "Error: ${exitError}\n\n";
}

function displayHelp()
{
    local exitError=$1;
    if [ -z "${exitError}" ]; then
        exitCode=0;
    fi

    if [ "${exitCode}" != "0" ]; then
        displayError "${exitError}";
    fi

    printf "docker-phpqa 0.0.1\n\n";
    printf "Usage:\n";
    printf "\tphpqa <path/to/test.phpt|suite> [<version>]\n\n";

    exit ${exitCode};
}

function parseRunArgs()
{
    _RUN_FILE_PATH=$1
    _RUN_VERSION=$2;

    if [ -z "${_RUN_FILE_PATH}" ] || [ ! -f "${_RUN_FILE_PATH}" ]; then
        displayHelp "You need to provide a phpt file to be tested or pass \`suite\` as first parameter to run the full test suite.";
    fi

    if [ -z "${_RUN_VERSION}" ]; then
        _RUN_VERSION=71; # default version is the stable one
    elif [ "${_RUN_VERSION}" != "72" ] && [ "${_RUN_VERSION}" != "71" ] && [ "${_RUN_VERSION}" != "70" ] && [ "${_RUN_VERSION}" != "56" ]; then
        displayHelp "The versions supported are 55, 56, 70, 71, 72 or all to run in all available versions.";
    fi
}

function parseArgs()
{
    _COMMAND=$1;
    if [ -z "${_COMMAND}" ] || ( [ "${_COMMAND}" != "run" ] && [ "${_COMMAND}" != "generate" ] ); then
        displayHelp "Unrecognized command ${_COMMAND}.";
    fi

    if [ "${_COMMAND}" = "help" ]; then
        displayHelp;
    fi

    shift;
    _COMMAND_ARGS=$@;
}

function executeRunSuite()
{
    docker run --rm -i -t herdphp/phpqa:${_RUN_VERSION} make test;
    exit 0;
}

function fixPath()
{
    _RUN_FILENAME=${_RUN_FILE_PATH##*/};
    if [[ ! "$_RUN_FILE_PATH" = /* ]]; then
        _RUN_FILE_PATH="$(pwd)/${_RUN_FILE_PATH}";
    fi
}

function singleTest()
{
    docker run --rm -i -t \
        -v ${_RUN_FILE_PATH}:/usr/src/phpt/${_RUN_FILENAME} herdphp/phpqa:${_RUN_VERSION} \
        make test TESTS=/usr/src/phpt/${_RUN_FILENAME};
}

function executeRun()
{
    parseRunArgs ${_COMMAND_ARGS};

    if [ "${_RUN_VERSION}" = "all" ]; then
        $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_RUN_FILENAME} 72;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_RUN_FILENAME} 71;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_RUN_FILENAME} 70;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_RUN_FILENAME} 56;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_RUN_FILENAME} 55;
        exit 0;
    fi

    if [ "$_RUN_FILE" = "suite" ]; then
        executeRunSuite;
    fi

    fixPath;
    singleTest;
}

# @todo add generation logic
function executeGenerate()
{
    echo "TODO";
}

function executeCommand()
{
    local command=$1;
    local commandFunction="$(tr a-z A-Z <<< ${command:0:1})${command:1}";

    "execute${commandFunction}" ${_COMMAND_ARGS};
}

function main()
{
    parseArgs $@;
    executeCommand ${_COMMAND};
}

main $@;

