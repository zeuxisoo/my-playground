all:
	@echo
	@echo "Command     : Description"
	@echo "----------- : -----------"
	@echo "make venv   : create virtual environment"
	@echo "make vendor : install the application dependencies"
	@echo "make watch  : run watchdog script for compare"
	@echo

venv:
	python3 -m venv venv

vendor:
	source venv/bin/activate && pip install -r requirements.txt

watch:
	@echo "start watching ..."
	@./venv/bin/watchmedo shell-command \
	    --patterns='*' \
    	--recursive \
       	--command='echo "[$${watch_event_type}] [$${watch_object}] $${watch_src_path} -> $${watch_dest_path}"' \
    	./project
