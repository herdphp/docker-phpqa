#!/usr/bin/env bash

# Grabs filepath argument
_PHPT_FILE_PATH=$1;
if [ -z "$_PHPT_FILE_PATH" ]; then
    printf "docker-phpqa 0.0.1\n\n";
    printf "Usage:\n";
    printf "\t./phpqa <path/to/test.phpt|suite> [<version>]\n\n";
    printf "Notes:\n";
    printf "\t- you need to provide a phpt file to be tested or pass \`suite\` as first parameter to run the full test suite.\n";
    printf "\t- the versions supported are 55, 56, 70, 71 or all (run all available versions).\n";
    exit 1;
fi

# Grabs version argument
_VERSION=$2
if [ -z "$_VERSION" ]; then
    _VERSION=71;
elif [ "$_VERSION" = "all" ]; then
    # $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 72; @see: https://bugs.php.net/bug.php?id=74723
    $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_PHPT_FILE_PATH} 71;
    $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_PHPT_FILE_PATH} 70;
    $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_PHPT_FILE_PATH} 56;
    $(git rev-parse --show-toplevel)/bin/phpqa.sh ${_PHPT_FILE_PATH} 55;
    exit 0;
fi

# Running full suite
if [ "$_PHPT_FILE_PATH" = "suite" ]; then
    docker run --rm -i -t herdphp/phpqa:${_VERSION} make test;
    exit 0;
fi

# Fixing relative paths
_PHPT_FILENAME=${_PHPT_FILE_PATH##*/};
if [[ ! "$_PHPT_FILE_PATH" = /* ]]; then
    _PHPT_FILE_PATH="$(pwd)/${_PHPT_FILE_PATH}";
fi

# Running single test
docker run --rm -i -t \
    -v ${_PHPT_FILE_PATH}:/usr/src/phpt/${_PHPT_FILENAME} herdphp/phpqa:${_VERSION} \
    make test TESTS=/usr/src/phpt/${_PHPT_FILENAME};