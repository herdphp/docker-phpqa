#!/usr/bin/env bash

_PHPT_FILE_PATH=$1
if [ -z "$_PHPT_FILE_PATH" ]; then
    echo "You need to provide a phpt file to be tests."
    echo "usage:"
    echo "./phpqa path/to/test.phpt <version>"
    echo "available versions: 56, 70, 71 and all (run all available versions)"
    exit 1;
fi

_VERSION=$2
if [ -z "$_VERSION" ]; then
    _VERSION=71
elif [ "$_VERSION" = "all" ]; then
    # $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 72 @see: https://bugs.php.net/bug.php?id=74723
    $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 71
    $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 70
    $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 56
    $(git rev-parse --show-toplevel)/bin/phpqa.sh $1 55
    exit 0;
fi

docker run --rm -i -t \
    -v $(git rev-parse --show-toplevel)/phpt:/usr/src/phpt herdphp/phpqa:${_VERSION} \
    make test TESTS=/usr/src/${_PHPT_FILE_PATH}