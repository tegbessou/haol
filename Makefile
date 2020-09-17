DOCKER-COMPOSE = docker-compose
EXEC_PHP = docker-compose exec -u www-data php
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

reset: stop start ##Reset the project

composer-install: composer.lock ##Install composer
	$(COMPOSER) install

composer-update: composer.json ##Update composer
	$(COMPOSER) update

cache-clear: ##Clear symfony cache
	$(EXEC_PHP) bin/console c:c