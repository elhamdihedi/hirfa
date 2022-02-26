DOCKER_COMPOSE = docker-compose
EXEC_ARGS?=-T
EXEC?=$(DOCKER_COMPOSE) exec $(EXEC_ARGS) php
COMPOSER=$(EXEC) composer
CONSOLE=$(EXEC) bin/console
EXEC_PHP =$(EXEC) php

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
composer-install: ## Command reads the composer.json file to resolves the dependencies, and installs them.
	@echo -e "\e[32mInstall dependencies...\e[0m"
	$(COMPOSER) install

composer-update: ## Resolve all dependencies of the project and write the exact versions into composer.lock
	@echo -e "\e[32mUpdate dependencies...\e[0m"
	$(COMPOSER) update  
##
## Database
##---------------------------------------------------------------------------
db: db-init ## Reset the database and load fixtures
	$(CONSOLE) doctrine:fixtures:load -n --no-debugfo

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

analyse: composer-valid container-linter phpcpd phpstan

phpstan: ## Search for possible errors
	@echo -e "\e[32mRunning phpstan...\e[0m"
	$(EXEC_PHP) vendor/bin/phpstan analyse --configuration=phpstan.neon --memory-limit=4G

php-cs-fixer: ## Corrects the code to meet the standards
	@echo -e "\e[32mRunning php-cs-fixer...\e[0m"
	@$(EXEC_PHP) vendor/bin/php-cs-fixer fix

phpcpd: ## Detects code duplicates
	@echo -e "\e[32mRunning phpcpd...\e[0m"
	@$(EXEC_PHP) vendor/bin/phpcpd src

container-linter: ## Guarantees that the arguments injected in the services correspond to the type declarations.
	@echo -e "\e[32mRunning container linter...\e[0m"
	$(CONSOLE) lint:container
security-check: vendor                                                                                 ## Check for vulnerable dependencies
	$(EXEC) local-php-security-checker --path=/app

composer-valid: ## Checks if your composer.json is valid.
	@echo -e "\e[32mRunning composer validate...\e[0m"
	$(COMPOSER) valid

##
## Tests
##---------------------------------------------------------------------------
tests:  ## Run all tests
	@echo -e "\e[32mRunning tests...\e[0m"
	@$(EXEC_PHP) bin/phpunit
component-tests: ## Run all component tests
	@echo -e "\e[32mRunning component tests...\e[0m"
	@echo -e "\e[1;93mReminder :To test is to doubt :)\e[0m"
	@$(EXEC_PHP) bin/phpunit

integration-tests: ## Run all integration tests
	@echo -e "\e[32mRunning integration tests...\e[0m"
	@echo -e "\e[1;93mReminder :To test is to doubt :)\e[0m"
	@$(EXEC_PHP) bin/phpunit

functional-tests: ## Run all functional tests
	@echo -e "\e[32mRunning functional tests...\e[0m"
	@echo -e "\e[1;93mReminder :To test is to doubt :)\e[0m"
	@$(EXEC_PHP) bin/phpunit
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