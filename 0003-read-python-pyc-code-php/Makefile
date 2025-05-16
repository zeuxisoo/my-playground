all:
	@echo "Command    : Description"
	@echo "---------- : -----------"
	@echo "make pyc   : Generate the pyc file"
	@echo "make clean : Clean the cache file and so on"
	@echo "make test  : Run the php and python test file"

pyc:
	@python3 -m compileall dummy.py

clean:
	@rm -rf __pycache__

test: pyc
	@echo
	@echo "== PHP =>"
	@php index.php

	@echo
	@echo "== Python =>"
	@python3 index.py
