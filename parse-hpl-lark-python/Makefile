all:
	@echo
	@echo "Command        : Description"
	@echo "-------------- : -----------"
	@echo "make venv      : create virtual environment"
	@echo "make vendor    : install the application dependencies"
	@echo "make benchmark : run the benchmark"
	@echo

venv:
	python3 -m venv venv

vendor:
	source venv/bin/activate && pip install -r requirements.txt

benchmark:
	@echo
	@hyperfine \
		--warmup 9 --runs 10 \
		-n "walk 1" "./venv/bin/python3 main.py --walker=1" \
		-n "walk 2" "./venv/bin/python3 main.py --walker=2" \
		-n "walk 3" "./venv/bin/python3 main.py --walker=3" \
		-n "walk 4" "./venv/bin/python3 main.py --walker=4"
