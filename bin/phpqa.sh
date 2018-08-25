#!/usr/bin/env bash

_YELLOW='\033[1;33m' # yellow color
_GREEN='\033[0;32m' # green color
_NC='\033[0m' # no color

_PHPQA_PHP_VERSION=71;

function defineScriptDir()
{
    local scriptPath;
    if [ "$(uname)" == "Darwin" ]; then
        scriptPath=$(readlink $0);
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        scriptPath=$(readlink -f $0);
    fi

    _PHPQA_DIR=$(dirname "${scriptPath}");
}

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
    printf "${_YELLOW}GENERAL usage${_NC}:
    phpqa gcov ....................... Generate GCOV report to all tests 
    phpqa help ....................... Display this help message
    phpqa update ..................... Update scripts and Docker images\n";
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
    phpqa run <path/to/test.phpt|suite> [<version>]\n";

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
    elif [ "${_RUN_VERSION}" != "all" ] && [ "${_RUN_VERSION}" != "master" ] && [ "${_RUN_VERSION}" != "72" ] && [ "${_RUN_VERSION}" != "71" ] && [ "${_RUN_VERSION}" != "70" ] && [ "${_RUN_VERSION}" != "56" ] && [ "${_RUN_VERSION}" != "55" ]; then
        displayHelp "The versions supported are 55, 56, 70, 71, 72, master or all to run in all available versions.";
    fi
}

function updateAll()
{
    printf "${_YELLOW}[Update 1/2]${_NC} Updating docker-phpqa scripts...\n"
    pushd ${_PHPQA_DIR}
    git pull
    popd
    printf "${_GREEN}[Update 1/2]${_NC} Scripts updated!\n"
    printf "${_YELLOW}[Update 2/2]${_NC} Updating docker-lphpqa Docker images...\n"
    docker pull herdphp/phpqa:master;
    docker pull herdphp/phpqa:72;
    docker pull herdphp/phpqa:71;
    docker pull herdphp/phpqa:70;
    docker pull herdphp/phpqa:56;
    docker pull herdphp/phpqa:55;
    printf "${_GREEN}[Update 2/2]${_NC} Docker images updated!\n"
    printf "${_GREEN}Your docker-phpqa is now fully updated.${_NC}\n"

    exit 0;
}

function parseArgs()
{
    _COMMAND=$1;
    if [ -z "${_COMMAND}" ] || [ "${_COMMAND}" = "help" ]; then
        displayHelp;
    fi

    _COMMAND=$1;
    if [ "${_COMMAND}" = "update" ]; then
        updateAll;
    fi

    if [ "${_COMMAND}" != "run" ] && [ "${_COMMAND}" != "generate" ] && [ "${_COMMAND}" != "help" ] && [ "${_COMMAND}" != "gcov" ]; then
        displayHelp "Unrecognized command ${_COMMAND}.";
    fi

    shift;
    _COMMAND_ARGS=$@;
}

function executeRunSuite()
{
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
    docker run --rm -i -t \
        -v ${_RUN_FILE_DIR}/${_RUN_VERSION}/:/usr/src/phpt/ \
        herdphp/phpqa:${_RUN_VERSION} \
        make test TESTS=/usr/src/phpt/${_RUN_FILENAME} \
        | sed -e "s/Build complete./Test build successfully./" -e "s/Don't forget to run 'make test'./=\)/";
    
    printf "${_NC}==================================================\n";
    printf "${_NC}DIFF\n";
    printf "${_NC}==================================================\n";
    docker run --rm -i -t \
        -v ${_RUN_FILE_DIR}/${_RUN_VERSION}/:/usr/src/phpt/ \
        herdphp/phpqa:${_RUN_VERSION} \
        cat /usr/src/phpt/${_RUN_FILENAME//phpt/diff};
    printf "\n${_NC}==================================================";
}

function executeRun()
{
    parseRunArgs ${_COMMAND_ARGS};

    if [ "${_RUN_VERSION}" = "all" ]; then
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} master;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} 72;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} 71;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} 70;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} 56;
        $(git rev-parse --show-toplevel)/bin/phpqa.sh run ${_RUN_FILE_PATH} 55;
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
    docker run --rm -i -t -w /usr/src/phpt -v ${_GENERATE_DIR}:/usr/src/phpt herdphp/phpqa:${_GENERATE_VERSION} \
        php /usr/src/php/scripts/dev/generate-phpt.phar ${_GENERATE_ARGS} | sed "s/php generate-phpt.php /phpqa/";
}

function executeCommand()
{
    local command=$1;
    local commandFunction="$(tr a-z A-Z <<< ${command:0:1})${command:1}";

    "execute${commandFunction}" ${_COMMAND_ARGS};
}

function executeGcov()
{
    _GCOV_VERSION=${_PHPQA_PHP_VERSION};
    if [ ! -z "${_RUN_FILE_PATH}" ]; then
        _GCOV_VERSION=$1;
    fi

    _GCOV_FOLDER=$(git rev-parse --show-toplevel)/phpt/gcov/${_GCOV_VERSION};
    mkdir -p ${_GCOV_FOLDER};

    docker run --rm -i -t -v ${_GCOV_FOLDER}:/usr/src/php/lcov_html herdphp/phpqa:${_GCOV_VERSION} make lcov;
    printf "${_GREEN}The coverage report were generated and is available at lcov_html/index.html \n"
    exit 0;
}


function main()
{
    defineScriptDir;
    parseArgs $@;
    executeCommand ${_COMMAND};
}

main $@;
