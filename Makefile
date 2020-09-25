DOCKER-COMPOSE = docker-compose
EXEC_PHP = docker-compose exec -u www-data php
EXEC_SYMFONY = docker-compose exec -u www-data php bin/console
EXEC_DB = docker-compose exec db sh -c
QUALITY_ASSURANCE = docker-compose run --rm quality-assurance
COMPOSER = $(EXEC_PHP) composer

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##Docker
build: ##Build docker
	$(DOCKER-COMPOSE) build

up: build ##Up docker
	$(DOCKER-COMPOSE) up -d

down: ##Down docker
	$(DOCKER-COMPOSE) down

##Project
start: up ##Start project

stop: down ##Stop project

reset: stop start db-load ##Reset the project

composer-install: composer.lock ##Install composer
	$(COMPOSER) install

composer-update: composer.json ##Update composer
	$(COMPOSER) update

cc: ##Clear symfony cache
	$(EXEC_SYMFONY) c:c

wait-db:
	@$(EXEC_PHP) php -r "set_time_limit(60);for(;;){if(@fsockopen('db',3306))die;echo \"Waiting for DB\n\";sleep(1);}"

##Database
db-load: wait-db db-fixtures ##Load database from dump

db-reload: wait-db db-drop db-create db-migrate ##Recreate database structure

db-create: ##Create database
	$(EXEC_SYMFONY) doctrine:database:create

db-drop: ##Drop database
	$(EXEC_SYMFONY) doctrine:database:drop --force --if-exists

db-diff: ##Generate migration by diff
	$(EXEC_SYMFONY) doctrine:migration:diff

db-migrate: ##Load migration
	$(EXEC_SYMFONY) doctrine:migration:migrate --no-interaction

db-reload-fixtures: db-reload ##Reload fixtures
	$(EXEC_SYMFONY) hautelook:fixtures:load --no-interaction
	$(EXEC_DB) "mysqldump --user=root --password=root --databases haol > /home/app/docker/db/dump/haol.sql"

db-fixtures: ##Load fixtures from dump
	$(EXEC_DB) "mysql --user=root --password=root < /home/app/docker/db/dump/haol.sql"

##Behat
behat: db-load ##Launch behat
	$(EXEC_PHP) vendor/bin/behat

##Quality assurance
security-checker: ##Security check on dependencies
	$(QUALITY_ASSURANCE) sh -c "security-checker security:check"

phpmd: ##Phpmd
	$(QUALITY_ASSURANCE) phpmd src/ text .phpmd.xml

composer-unused: ##Check if you have unused dependencies
	$(QUALITY_ASSURANCE) composer-unused

yaml-linter: ##Linter yaml
	$(QUALITY_ASSURANCE) yaml-linter . --format=json

phpstan:
	$(QUALITY_ASSURANCE) phpstan analyse src/ --level 8

cs:
	$(QUALITY_ASSURANCE) php-cs-fixer fix --dry-run --using-cache=no --verbose --diff

cs-fix:
	$(QUALITY_ASSURANCE) php-cs-fixer fix --using-cache=no --verbose --diff