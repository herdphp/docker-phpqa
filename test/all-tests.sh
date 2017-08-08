#!/usr/bin/env bash
function version_test()
{
    if [ ! -z "$1" ] && [ ! -z "$2" ]; then
        local build=$1;
        local version=$2;
        local versionContainer=$(docker run --rm -v `pwd`:`pwd` -w `pwd` herdphp/phpqa:${build} php ./test/version.php)
        if [[ ${versionContainer} == *"${version}"* ]]; then
            echo "Version ${build} -> ${versionContainer} test OK!";
        else
            echo "Version ${build} test Failed!";
            exit 1;
        fi
    fi
}

function all_builds_version_test()
{
    version_test 55 '5.5';
    version_test 56 '5.6';
    version_test 70 '7.0';
    version_test 71 '7.1';
    version_test 72 '7.2';
}

function all_tests()
{
    echo "Starting version tests";
    all_builds_version_test;
}
all_tests;
