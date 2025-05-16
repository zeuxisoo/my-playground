all:
	@echo "Command     : Description"
	@echo "----------- : -----------"
	@echo "make vendor : install the depdency package"
	@echo "make run    : run the program"

vendor:
	swift package resolve

run:
	rm -rf ./.build && swift build && swift run --skip-build
