all:
	@echo "Command  : Description"
	@echo "-------- : -------"
	@echo "make gen : generate shared library"
	@echo "make run : run the test.php"
	@echo

gen:
	@echo "generating ..."
	@v -shared test.v

run: gen
	@echo "running ...\n"
	@php test.php
