all:
	@echo "Command     : Description"
	@echo "----------- : -----------"
	@echo "make vendor : install the dependency package"
	@echo "make run    : run the program"

vendor:
	@nimble install checksums
	@nimble install https://github.com/nim-lang/bigints

run:
	@nim c -r --verbosity:0 src/main.nim
