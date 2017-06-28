# How To PHPT

First, let's set up the 'enviroment'.

- Clone this repo

```git clone https://github.com/herdphp/docker-phpqa.git ```


- Go to the created folder or the one you especified

``` cd docker-phpqa ```


- Create a folder for you to build and test some PHPT

``` mkdir phpt/username ```


PHPT have some conventions for file names
- {function-name}_basic.phpt (Tests for the default behaviour of the function)
- {function-name}\_error\_{number}.phpt (Tests for the errors of the function)
- {function-name}\_variation\_{number}.phpt (Tests for non default behaviours of the functions)
- {ext-name}{number}.phpt (Tests for functions that belongs to an extension)
- bug{bug-id}.phpt (Tests for bugs reported)

- Create a new file to build you first PHPT, for this tutorial we will write a test to check in_array usage

``` vim phpt/username/in_array_basic.phpt ```

##Content of the .phpt file
Sample:
```php
--TEST--
Testing correct usage of in_array
--CREDITS--
Your Name <user [at] domain [dot] com>
#phptestfest2017
--FILE--
<?php
$os = array('Mac', 'Windows', 'Linux');

if (in_array('Mac', $os)) {
    echo 'Mac Found';
}

?>
--EXPECT--
Mac Found
```

#### --TEST--

TEST block is use to add a description of waht is this PHPT testing

#### --CREDITS--

CREDITS block is your credentials and maybe the testfest you participated :D

#### --FILE--

FILE block is where you add php code to test what you need, plain and simple PHP

### --EXPECT-- or --EXPECTF--

EXPECT or EXPECTF block is the output message that php should return

EXPECT for the correct usage

EXPECTF for the error usage

## Now, let's roll!

``` phpqa phpt/username ```

Console Output

```

=====================================================================
Running selected tests.
PASS Testing correct usage of in_array [/usr/src/phpt/username/in_array_basic.phpt]
=====================================================================
Number of tests :    1                 1
Tests skipped   :    0 (  0.0%) --------
Tests warned    :    0 (  0.0%) (  0.0%)
Tests failed    :    0 (  0.0%) (  0.0%)
Expected fail   :    0 (  0.0%) (  0.0%)
Tests passed    :    1 (100.0%) (100.0%)
---------------------------------------------------------------------
Time taken      :    0 seconds
=====================================================================
```

All good! Now let's test the function for an error.

First, we need to change the **--EXPECT--** tag to **--EXPECTF--**
this is the correct block name to validate an error and the **--TEST--** block description

- Create a file to build a in_array error PHPT

``` vim phpt/username/in_array_error.phpt ```

Change something that will generate an error output, in this example, change _$os_ var to something that is not an array

Content of the .phpt file
```php
--TEST--
Testing wrong usage of in_array
--CREDITS--
Your Name <user [at] domain [dot] com>
#phptestfest2017
--FILE--
<?php
$os = '';

if (in_array('Mac', $os)) {
    echo 'Mac Found';
}

?>
--EXPECTF--
Mac Found
```

- Run the test to see the output

```phpqa phpt/username ```

You should get an console output like this
```

=====================================================================
Running selected tests.
PASS Testing correct usage of in_array [/usr/src/phpt/username/in_array_basic.phpt]
FAIL Testing wrong usage of in_array [/usr/src/phpt/username/in_array_error.phpt]
=====================================================================
Number of tests :    2                 2
Tests skipped   :    0 (  0.0%) --------
Tests warned    :    0 (  0.0%) (  0.0%)
Tests failed    :    1 ( 50.0%) ( 50.0%)
Expected fail   :    0 (  0.0%) (  0.0%)
Tests passed    :    1 ( 50.0%) ( 50.0%)
---------------------------------------------------------------------
Time taken      :    0 seconds
=====================================================================

=====================================================================
FAILED TEST SUMMARY
---------------------------------------------------------------------
Testing wrong usage of in_array [/usr/src/phpt/username/in_array_error.phpt]
=====================================================================
```

## Now let's see the **log** files

#### .EXP
Result of the **--EXPECT--** or **--EXPECTF--** block of the phpt file

```less phpt/username/in_array_error.exp```

```
Mac Found
```

#### .OUT

PHP output message for the code that was executed

```less phpt/username/in_array_error.out```

```
Warning: in_array() expects parameter 2 to be array, string given in /usr/src/phpt/username/in_array_error.phpt on line 4
```

### .PHP

**--FILE--** Block code, the PHP code that was executed during the test

```less phpt/username/in_array_error.phpt```

```php
<?php
$os = '';

if (in_array('Mac', $os)) {
    echo 'Mac Found';
}

?>
```

### .SH

Command used to run the test to reproduce what the suit did

```less phpt/username/in_array_error.sh```

```
#!/bin/sh

/usr/src/php/sapi/cli/php  -n -c '/usr/src/php/tmp-php.ini'  -d "output_handler=" -d "open_basedir=" -d "disable_functions=" -d "output_buffering=Off" -d "error_reporting=32767" -d "display_errors=1" -d "display_startup_errors=1" -d "log_errors=0" -d "html_errors=0" -d "track_errors=1" -d "report_memleaks=1" -d "report_zend_debug=0" -d "docref_root=" -d "docref_ext=.html" -d "error_prepend_string=" -d "error_append_string=" -d "auto_prepend_file=" -d "auto_append_file=" -d "ignore_repeated_errors=0" -d "precision=14" -d "memory_limit=128M" -d "log_errors_max_len=0" -d "opcache.fast_shutdown=0" -d "opcache.file_update_protection=0" -d "extension_dir=/usr/src/php/modules/" -d "zend_extension=/usr/src/php/modules/opcache.so" -d "session.auto_start=0" -d "zlib.output_compression=Off" -d "mbstring.func_overload=0" -f "/usr/src/phpt/username/in_array_error.phpt"  2>&1

```

## Useful **logs**
Those files can help you to see the exact output and what you need to change on your test

```less phpt/username/in_array_error.diff```

```
001+ Warning: in_array() expects parameter 2 to be array, string given in /usr/src/phpt/username/in_array_error.phpt on line 4
001- Mac Found
```

```less phpt/username/in_array_error.log```

```
---- EXPECTED OUTPUT
Mac Found
---- ACTUAL OUTPUT
Warning: in_array() expects parameter 2 to be array, string given in /usr/src/phpt/username/in_array_error.phpt on line 4
---- FAILED
```

## Fixing .phpt file
In this example, you need to change your **--EXPECTF--** block to
```
Warning: in_array() expects parameter 2 to be array, string given in /usr/src/phpt/username/in_array_error.phpt on line 4
```

But, to make this test run smoothly in all version and to make it easier to be changed, let's get rid of the static things like
numbers and types.

Change 'string' to the wildcard '%s', this way the test will be good to validate not only strings but also the wrong parameter type.
```
Warning: in_array() expects parameter 2 to be array, %s given in /usr/src/phpt/username/in_array_error.phpt on line 4
```

Let's change the script name and line just to make the output cleaner and future changes easier
```
Warning: in_array() expects parameter 2 to be array, %s given in %s on line %d
```

The wildcards are:
- %s - string
- %d - number
- %c - single char
- %w - whitespace
- %i - integer
- %f - float
- %x - hexadecimal
- %e - directory separator

Run again

```phpqa phpt/username```

If all works good, the log files will be deleted and you will get something like this

```

=====================================================================
Running selected tests.
PASS Testing correct usage of in_array [/usr/src/phpt/username/in_array_basic.phpt]
PASS Testing wrong usage of in_array [/usr/src/phpt/username/in_array_error.phpt]
=====================================================================
Number of tests :    2                 2
Tests skipped   :    0 (  0.0%) --------
Tests warned    :    0 (  0.0%) (  0.0%)
Tests failed    :    0 (  0.0%) (  0.0%)
Expected fail   :    0 (  0.0%) (  0.0%)
Tests passed    :    2 (100.0%) (100.0%)
---------------------------------------------------------------------
Time taken      :    0 seconds
=====================================================================
```

Good testing!