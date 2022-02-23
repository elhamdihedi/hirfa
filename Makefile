DOCKER_COMPOSE = docker-compose
EXEC_ARGS?=-it
EXEC?=$(DOCKER_COMPOSE) exec $(EXEC_ARGS) php bash php
COMPOSER=$(EXEC) composer
CONSOLE=$(EXEC) bin/console


help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##
## Project setup
##---------------------------------------------------------------------------

build: ## Build all dockers images in local ways
	@echo -e "\e[32mBuilding local images...\e[0m"
	@$(DOCKER_COMPOSE) build
start: ## Starts existing containers for a service
	@echo -e "\e[32mStart containers...\e[0m"
	$(DOCKER_COMPOSE) unpause || true
	$(DOCKER_COMPOSE) start  || true

stop: ## Stops running containers without removing them
	@echo -e "\e[32mStop containers...\e[0m"
	$(DOCKER_COMPOSE) pause || true
up: ## Builds, (re)creates, starts, and attaches to containers for a service
	@echo -e "\e[32mUp environment...\e[0m"
	@$(DOCKER_COMPOSE) up -d --remove-orphans
down:## Stops containers and removes containers, networks, volumes, and images created by up.
	@echo -e "\e[32mDown environment...\e[0m"
	@$(DOCKER_COMPOSE) kill
	@$(DOCKER_COMPOSE) down --remove-orphans

##
## Database
##---------------------------------------------------------------------------
db: db-init ## Reset the database and load fixtures
	$(CONSOLE) doctrine:fixtures:load -n --no-debug

db-init: vendor   ## Init the database
	@echo -e "\e[32mSetup database...\e[0m"
	$(CONSOLE) doctrine:database:drop --force --if-exists --no-debug
	$(CONSOLE) doctrine:database:create --if-not-exists --no-debug
	$(CONSOLE) doctrine:migrations:migrate -n --no-debug
db-diff: vendor   ## Generate a migration by comparing your current database to your mapping information
	$(CONSOLE) doctrine:migration:diff --formatted --no-debug

db-diff-dump: vendor   ## Generate a migration by comparing your current database to your mapping information and display it in console
	$(CONSOLE) doctrine:schema:update --dump-sql

db-migrate: vendor   ## Migrate database schema to the latest available version
	$(CONSOLE) doctrine:migration:migrate -n --no-debug

db-rollback: vendor   ## Rollback the latest executed migration
	$(CONSOLE) doctrine:migration:migrate prev -n --no-debug

db-load: vendor  ## Reset the database fixtures
	$(CONSOLE) doctrine:fixtures:load -n --no-debug

db-validate: vendor  ## Check the ORM mapping
	$(CONSOLE) doctrine:schema:validate --no-debug

##
## Tests
##---------------------------------------------------------------------------

##
## Dependencies
##---------------------------------------------------------------------------
# Rules from files

vendor: vendor/composer/installed.php

vendor/composer/installed.php: composer.lock
	$(COMPOSER) install -n

composer.lock: composer.json
	@echo composer.lock is not up to date.

node_modules: yarn.lock
	$(EXEC) yarn install

yarn.lock: package.json
	@echo yarn.lock is not up to date.

##
## Containers
##---------------------------------------------------------------------------