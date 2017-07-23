# docker-phpqa

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ee6f6e34d4b942c88ad17f3f3f4a36a2)](https://www.codacy.com/app/brunoric/docker-phpqa?utm_source=github.com&utm_medium=referral&utm_content=herdphp/docker-phpqa&utm_campaign=badger)

Docker tools to easily create and run tests for the [PHP-SRC][php-src]. The intent of this library is to help any PHP 
developer to create PHPT tests for the language engine and its core extensions.

## How to get it?

1. You will **need** to have [docker](https://www.docker.com/community-edition) installed on your machine.

2. Run our installer:

````bash
curl -s https://raw.githubusercontent.com/herdphp/docker-phpqa/master/bin/installer.sh | bash
````

Start PHPTesting!!!

## How to use it?

### To generate new PHPT test files

The [generate-phpt][generate-phpt] tool wrapped by `docker-phpqa` is a developer tool 
[that lives inside of PHP-SRC repository][generate-phpt]. It' usage is very simple and the intent is to bootstrap PHPT
creation.

````
Usage:
./phpqa generate [PHPT_DIR] -f <function_name> |-c <class_name> -m <method_name> -b|e|v [-s skipif:ini:clean:done] [-k win|notwin|64b|not64b] [-x ext]

Where:
-f function_name ................. Name of PHP function, eg cos
-c class name .....................Name of class, eg DOMDocument
-m method name ....................Name of method, eg createAttribute
-b ............................... Generate basic tests
-e ............................... Generate error tests
-v ............................... Generate variation tests
-s sections....................... Create optional sections, colon separated list
-k skipif key..................... Skipif option, only used if -s skipif is used.
-x extension.......................Skipif option, specify extension to check for
-h ............................... Print this message
````

If you want to see the help you can just use:

````bash
phpqa generate -h
````

If you want to create a *basic* PHPT test for the [`ucfirst` function][php-function-ucfirst]:

````bash
phpqa generate -f ucfirst -b
````

This will create a template PHPT file for the function ucfirst inside of your PHPT default folder. If you want to choose
the PHPT directory where the files are generated you can pass if as the first argument of the generate command:

````bash
phpqa generate /path/to/phpt/dir -f ucfirst -b
````

### To run your created tests against multiple PHP versions

1. Write a PHPT test in **any folder**;
2. Run the `phpqa` command passing as arguments the filepath (relative or full) and the PHP version to run the test (72, 71, 70, 56, 55):

````bash
# without a version the test will run against PHP 7.1 codebase
phpqa run phpt/examples/closure_061.phpt
# with a version the test will run against the specified version
phpqa run phpt/examples/closure_061.phpt 56
# if you want you can pass `all` as second argument and the test will run against all versions
phpqa run phpt/examples/closure_061.phpt all
````

## How to .PHPT

[Build your first test](https://github.com/herdphp/docker-phpqa/wiki/How-To-PHPT)

## PHP versions available

PHP 5.5, 5.6, 7.0, 7.1 and 7.2 (Alpha3) are fully available and supported;

## Contributing

If you notice any bug or typo, please feel free to create an issue and/or open a pull request with the fix.

## PHPTestFest2017

This repository intent to facilitate participation and contribution in the PHP Test Festival. More information about it:

* [QA PHP TestFest](https://wiki.php.net/qa/testfest)
* [Some blog posts from Stefan Koopmanschap](http://leftontheweb.com/blog/categories/testfest)
* [Philip Norton's post on the UK PHP TestFest 2010](http://www.hashbangcode.com/blog/php-testfest-uk-2010-and-testing-php)
* [PHPBelgium slides for preparing for TestFest 2009](https://www.slideshare.net/PHPBelgium/preparation-for-php-test-fest-2009)
* [PHPTestFestBrasil](https://phptestfestbrasil.github.io)
* [Sammy's php|tek 2017 talk](https://speakerdeck.com/sammyk/writing-tests-for-php-source-php-tek-2017)
* [Discussion at PHP User Groups list](https://groups.google.com/a/phpcommunity.org/forum/?utm_medium=email&utm_source=footer#!topic/testfest/-C2pcxod65g)
* [Testing with .php files on PHP Internals Book](https://www.phpinternalsbook.com/tests/introduction.html)

## Credits

* The tests in the examples folder are part of the [PHP interpreter codebase][php-src] distributed under [PHP License 3.01][php-license].
* The Dockerfile in this repository is inspired and based on the official Dockerfile template and images present in the
[PHP Docker Hub repository][php-docker] also available at the [Docker Library Github repository][docker-lib-php]. The
scripts `docker-php-*` are also from the same [repository][docker-lib-php]. These source code is distributed under [MIT license][docker-lib-php-license].

## LICENSE

Copyright (c) 2017 Bruno Ricardo Siqueira, Joao Paulo Vendramini Martins

This work is licensed under the terms of the [MIT license][license].

[php-src]: https://github.com/php/php-src
[php-docker]: https://hub.docker.com/_/php/
[php-license]: https://github.com/php/php-src/blob/master/LICENSE
[docker-lib-php]: https://github.com/docker-library/php
[docker-lib-php-license]: https://github.com/docker-library/php/blob/master/LICENSE
[license]: https://github.com/herdphp/docker-phpqa/blob/master/LICENSE
[generate-phpt]: https://github.com/php/php-src/tree/master/scripts/dev/generate-phpt
[php-function-ucfirst]: http://php.net/manual/en/function.ucfirst.php
