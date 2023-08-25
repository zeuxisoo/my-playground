all:
	@echo "Command     : Description"
	@echo "----------- : -----------"
	@echo "make server : start the development server"
	@echo "make build  : build the dist for production"

server:
	@yarn run dev

build:
	@echo "encodeing python"
	@node scripts/encode.js
	@mkdir -p public/assets
	@mv src/python/convert.py.bin public/assets/convert.py.bin
	@yarn run build
