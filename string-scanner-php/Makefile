all:
	@echo "Command       : Description"
	@echo "------------- : -----------"
	@echo "make composer : install composer.phar"
	@echo "make install  : install dependencies"
	@echo "make test     : run test case"
	@echo "make clean    : clean the install dependencies"

composer:
	curl https://getcomposer.org/download/latest-stable/composer.phar -o composer.phar

install:
	php composer.phar install

test:
	php ./vendor/bin/phpunit

clean:
	rm -rf ./vendor
