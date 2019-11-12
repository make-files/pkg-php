# PHP_PHPUNIT_REQ is a space separated list of prerequisites needed to run the
# PHPUnit tests.
PHP_PHPUNIT_REQ +=

################################################################################

# _PHP_PHPUNIT_INI_FILE is the path to a PHP INI file that should be used when
# running PHPUnit tests.
_PHP_PHPUNIT_INI_FILE ?= $(shell PATH="$(PATH)" find-file php.phpunit.ini)

# _PHP_PHPUNIT_REQ is a space separated list of automatically detected
# prerequisites needed to run the PHPUnit tests.
_PHP_PHPUNIT_REQ += $(_PHP_PHPUNIT_INI_FILE) $(PHP_PHPUNIT_CONFIG_FILE) $(PHP_SOURCE_FILES) $(_PHP_TEST_ASSETS)

# _PHP_PHPUNIT_RUNTIME_ARGS is a set of arguments to pass to the PHP runtime
# when running PHPUnit tests.
ifeq ($(_PHP_PHPUNIT_INI_FILE),)
_PHP_PHPUNIT_RUNTIME_ARGS +=
else
_PHP_PHPUNIT_RUNTIME_ARGS += -c "$(_PHP_PHPUNIT_INI_FILE)"
endif

################################################################################

# test --- Executes all tests in this package. Stacks with test targets from
# other test runners.
.PHONY: test
test:: test-phpunit

# coverage --- Produces an HTML coverage report. Stacks with coverage targets
# from other test runners.
.PHONY: coverage
coverage:: coverage-phpunit

# coverage-open --- Opens all HTML coverage reports in a browser. Stacks with
# coverage-open targets from other test runners.
.PHONY: coverage-open
coverage-open:: coverage-phpunit-open

# test-phpunit --- Executes all PHPUnit tests in this package.
.PHONY: test-phpunit
test-phpunit: $(PHP_PHPUNIT_REQ) $(_PHP_PHPUNIT_REQ) | vendor
	php $(_PHP_PHPUNIT_RUNTIME_ARGS) vendor/bin/phpunit -c $(PHP_PHPUNIT_CONFIG_FILE) --no-coverage

# coverage-phpunit --- Produces a PHPUnit HTML coverage report.
.PHONY: coverage-phpunit
coverage-phpunit: artifacts/coverage/phpunit/index.html

# coverage-phpunit-open --- Opens the PHPUnit HTML coverage report in a browser.
.PHONY: coverage-phpunit-open
coverage-phpunit-open: artifacts/coverage/phpunit/index.html
	open "$<"

# prepare --- Perform tasks that need to be executed before committing. Stacks
# with the "prepare" target form the common makefile.
.PHONY: prepare
prepare:: test

# ci --- Builds a machine-readable coverage report. Stacks with the "ci" target
# from the common makefile.
.PHONY: ci
ci:: artifacts/coverage/phpunit/clover.xml

################################################################################

artifacts/coverage/phpunit/index.html: $(PHP_PHPUNIT_REQ) $(_PHP_PHPUNIT_REQ) | vendor
	phpdbg $(_PHP_PHPUNIT_RUNTIME_ARGS) -qrr vendor/bin/phpunit -c $(PHP_PHPUNIT_CONFIG_FILE) --coverage-html="$(@D)"

artifacts/coverage/phpunit/clover.xml: $(PHP_PHPUNIT_REQ) $(_PHP_PHPUNIT_REQ) | vendor
	phpdbg $(_PHP_PHPUNIT_RUNTIME_ARGS) -qrr vendor/bin/phpunit -c $(PHP_PHPUNIT_CONFIG_FILE) --coverage-clover="$@"
