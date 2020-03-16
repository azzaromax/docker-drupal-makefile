PROJECT_DIR = $(PWD)
PREFIX = $(shell basename $(CURDIR) | tr A-Z a-z)
UID = $$(id -u)
C_PHP = ${PREFIX}_php_1

selfupdate:
	rm -rf docker-drupal-makefile
	rm Makefile
	git clone git@github.com:azzaromax/docker-drupal-makefile.git
	mv docker-drupal-makefile/Makefile ./
	rm -rf docker-drupal-makefile

docker.build:
	docker-compose up -d --remove-orphans --build

docker.run:
	docker-compose up -d --remove-orphans

docker.restart:
	docker-compose stop
	make run

docker.enter:
	docker exec -it -u ${UID} ${C_PHP} bash

docker.composer.install:
	docker exec -u ${UID} ${C_PHP} composer install

docker.drupal.config-export:
	docker exec -u ${UID} ${C_PHP} ./bin/drush cex -y

docker.drupal.config-import:
	make composer.install
	make drupal.cache-rebuild
	docker exec -u ${UID} ${C_PHP} ./bin/drush cim -y

docker.drupal.cache-rebuild:
	docker exec -u ${UID} ${C_PHP} ./bin/drush cr

docker.drupal.dump-database:
	make drupal.cache-rebuild
	docker exec -u ${UID} ${C_PHP} ./bin/drupal dbdu --file=dump.sql --gz

docker.drupal.dump-database-restore:
	docker exec -u ${UID} ${C_PHP} ./bin/drupal dbr --file=dump.sql.gz

docker.drupal.dump-project:
	rm -f ${PREFIX}.tar.gz
	make drupal.config-export
	make drupal.dump-database
	tar -cvz  --exclude='.git' --exclude='composer' --exclude='.idea' -f  ${PREFIX}.tar.gz .

drupal.dump-files:
	tar fcvz files.tar.gz ./sites/default/files

drupal.dump-files-restore:
	tar fxvz files.tar.gz
