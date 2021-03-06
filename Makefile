#
# Makefile by Carl J. Nobile
#

PREFIX		= $(shell pwd)
PACKAGE_DIR	= $(shell echo $${PWD\#\#*/})
LOGS_DIR	= $(PREFIX)/logs
DOCS_DIR	= $(PREFIX)/docs
TODAY		= $(shell date +"%Y-%m-%d_%H%M")
RM_REGEX	= '(^.*.pyc$$)|(^.*.wsgic$$)|(^.*~$$)|(.*\#$$)|(^.*,cover$$)'
RM_CMD		= find $(PREFIX) -regextype posix-egrep -regex $(RM_REGEX) \
                  -exec rm {} \;
COVERAGE_DIR	= $(PREFIX)/.coverage_tests
COVERAGE_FILE	= $(PREFIX)/.coveragerc
PIP_ARGS	= # Pass var for pip install.

#----------------------------------------------------------------------
all	: tar

#----------------------------------------------------------------------
.PHONY	: tar
tar	: clean
	@(cd ..; tar -czvf $(PACKAGE_DIR).tar.gz --exclude=".git" \
          --exclude="logs/*.log" --exclude="dist/*" $(PACKAGE_DIR))

.PHONY	: tests
tests	: clean
	@rm -rf $(DOCS_DIR)/htmlcov
#	export COVERAGE_PROCESS_START=$(COVERAGE_FILE)
	@nosetests --with-coverage --cover-erase --cover-html \
                   --cover-html-dir=$(DOCS_DIR)/htmlcov --nologcapture \
                   --cover-package=$(PREFIX)/daemonize --processes=-1 \
                   --process-restartworker #--nocapture
	coverage combine
	coverage report

.PHONY	: build
build	: clean
	python setup.py sdist

.PHONY	: upload
upload	: clobber
	python setup.py sdist
	python setup.py bdist_wheel --universal
	twine upload --repository pypi dist/*

.PHONY	: upload-test
upload-test: clobber
	python setup.py sdist
	python setup.py bdist_wheel --universal
	twine upload --repository testpypi dist/*

.PHONY	: install-dev
install-dev:
	pip install $(PIP_ARGS) -r requirements/development.txt

#----------------------------------------------------------------------
.PHONY	: clean
clean	:
	$(shell $(RM_CMD))
	@rm -rf *.egg-info
	@rm -rf dist

.PHONY	: clobber
clobber	: clean
	@rm -f $(LOGS_DIR)/*.log
	@rm -f $(LOGS_DIR)/*.pid
	@rm -rf __pycache__
