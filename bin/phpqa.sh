#!/usr/bin/env bash

_YELLOW='\033[1;33m' # yellow color
_GREEN='\033[0;32m' # green color
_NC='\033[0m' # no color

_PHPQA_PHP_VERSION=71;

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

    printf "${_GREEN}docker-phpqa - Docker tools to easily create and run tests for the PHP-SRC${_NC}\n";
    printf "${_YELLOW}GENERATE usage${_NC}:
    phpqa generate [PHPT_DIR] -f <function_name> |-c <class_name> -m <method_name> -b|e|v [-s skipif:ini:clean:done] [-k win|notwin|64b|not64b] [-x ext]
    Where:
    -f function_name ................. Name of PHP function, eg cos
    -c class name .................... Name of class, eg DOMDocument
    -m method name ................... Name of method, eg createAttribute
    -b ............................... Generate basic tests
    -e ............................... Generate error tests
    -v ............................... Generate variation tests
    -s sections....................... Create optional sections, colon separated list
    -k skipif key..................... Skipif option, only used if -s skipif is used.
    -x extension...................... Skipif option, specify extension to check for
    -h ............................... Print this message\n";
    printf "${_YELLOW}RUN usage${_NC}:
    phpqa run <path/to/test.phpt|suite> [<version>]\n\n";

    exit ${exitCode};
}

function parseRunArgs()
{
    _RUN_FILE_PATH=$1
    _RUN_VERSION=$2;

    if [ -z "${_RUN_FILE_PATH}" ] || ([ ! -f "${_RUN_FILE_PATH}" ] && [ ! -d "${_RUN_FILE_PATH}" ] && [ ! "${_RUN_FILE_PATH}" = "suite" ]); then
        displayHelp "You need to provide a phpt or a directory with phpt files to be tested or pass \`suite\` as first parameter to run the full test suite.";
    fi

    if [ -z "${_RUN_VERSION}" ]; then
        _RUN_VERSION=${_PHPQA_PHP_VERSION};
    elif [ "${_RUN_VERSION}" != "72" ] && [ "${_RUN_VERSION}" != "71" ] && [ "${_RUN_VERSION}" != "70" ] && [ "${_RUN_VERSION}" != "56" ] && [ "${_RUN_VERSION}" != "55" ] && [ "${_RUN_VERSION}" != "all" ]; then
        displayHelp "The versions supported are 55, 56, 70, 71, 72 or all to run in all available versions.";
    fi
}

function parseArgs()
{
    _COMMAND=$1;
    if [ -z "${_COMMAND}" ] || [ "${_COMMAND}" = "help" ]; then
        displayHelp;
    fi

    if [ "${_COMMAND}" != "run" ] && [ "${_COMMAND}" != "generate" ] && [ "${_COMMAND}" != "help" ]; then
        displayHelp "Unrecognized command ${_COMMAND}.";
    fi

    shift;
    _COMMAND_ARGS=$@;
}

function executeRunSuite()
{
    docker pull herdphp/phpqa:${_RUN_VERSION};
    docker run --rm -i -t herdphp/phpqa:${_RUN_VERSION} make test;
    exit 0;
}

function fixRunPath()
{
    _RUN_FILENAME=${_RUN_FILE_PATH##*/};
    if [[ ! "${_RUN_FILE_PATH}" = /* ]]; then
        _RUN_FILE_PATH="$(pwd)/${_RUN_FILE_PATH}";
    fi
    _RUN_FILE_DIR=$(dirname "${_RUN_FILE_PATH}");
}

function singleTest()
{
    mkdir -p ${_RUN_FILE_DIR}/${_RUN_VERSION}/;
    cp -r ${_RUN_FILE_PATH} ${_RUN_FILE_DIR}/${_RUN_VERSION}/;
    docker pull herdphp/phpqa:${_RUN_VERSION};
    docker run --rm -i -t \
        -v ${_RUN_FILE_DIR}/${_RUN_VERSION}/:/usr/src/phpt/ \
        herdphp/phpqa:${_RUN_VERSION} \
        make test TESTS=/usr/src/phpt/${_RUN_FILENAME} \
        | sed -e "s/Build complete./Test build successfully./" -e "s/Don't forget to run 'make test'./=\)/";
}

function executeRun()
{
    parseRunArgs ${_COMMAND_ARGS};

    if [ "${_RUN_VERSION}" = "all" ]; then
        /usr/local/bin/phpqa run ${_RUN_FILE_PATH} 72;
        /usr/local/bin/phpqa run ${_RUN_FILE_PATH} 71;
        /usr/local/bin/phpqa run ${_RUN_FILE_PATH} 70;
        /usr/local/bin/phpqa run ${_RUN_FILE_PATH} 56;
        /usr/local/bin/phpqa run ${_RUN_FILE_PATH} 55;
        exit 0;
    fi

    if [ "${_RUN_FILE_PATH}" = "suite" ]; then
        executeRunSuite;
    fi

    fixRunPath;
    singleTest;
}

function parseGenerateArgs()
{
    local generateOptions="-f -c -m -b -e -v -s -k -x -h";
    _GENERATE_DIR=$1;
    _GENERATE_VERSION=${_PHPQA_PHP_VERSION};

    if [ -z "${_GENERATE_DIR}" ] || [[ ${generateOptions} =~ (^|[[:space:]])${_GENERATE_DIR}($|[[:space:]]) ]]; then
        _GENERATE_DIR="$(pwd)";
        _GENERATE_ARGS=$@;
    fi

    if [ ! -d "${_GENERATE_DIR}" ]; then
        displayHelp "Directory ${_GENERATE_DIR} does not exist.";
    fi

    if [ -z "${_GENERATE_ARGS}" ]; then
        shift;
        _GENERATE_ARGS=$@;
    fi
}

function fixGenerateDir()
{
    if [[ ! "${_GENERATE_DIR}" = /* ]]; then
        _GENERATE_DIR="$(pwd)/${_GENERATE_DIR}";
    fi
}

function executeGenerate()
{
    parseGenerateArgs ${_COMMAND_ARGS};
    fixGenerateDir;
    docker pull herdphp/phpqa:${_GENERATE_VERSION};
    docker run --rm -i -t -w /usr/src/phpt -v ${_GENERATE_DIR}:/usr/src/phpt herdphp/phpqa:${_GENERATE_VERSION} \
        php /usr/src/php/scripts/dev/generate-phpt.phar ${_GENERATE_ARGS} | sed "s/php generate-phpt.php /phpqa/";
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
