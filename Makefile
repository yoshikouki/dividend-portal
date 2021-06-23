IMAGE_BASE_PATH =
CI_IMAGE_NAME := $(IMAGE_BASE_PATH)yoshikouki/dividend-portal
IMAGE_TAG = latest
APP_CONTAINER_NAME=$(shell docker compose ps | grep -o -e "dividend-portal_app\w*")

INFO_COLOR=\033[1;34m
RESET=\033[0m
BOLD=\033[1m

USER_NAME := $(shell git config --get user.name)

setup:
	docker compose build
	docker compose run --rm app bin/setup

run:
	docker compose up -d && docker attach $(APP_CONTAINER_NAME)

lint:
	@bundle exec rubocop

lint-a:
	@bundle exec rubocop -A

test:
	@bundle exec rspec $(P)

cron-ls:
	@bundle exec whenever

cron-update:
	@bundle exec whenever --update-crontab

docker/connect:
	@docker compose exec app bash

docker/lint:
	@docker compose run --rm app make lint

docker/lint-a:
	@docker compose run --rm app make lint-a

docker/test:
	@docker compose run --rm app make test

docker/build-ci:
	@echo "$(INFO_COLOR)==> $(RESET)$(BOLD)Build Docker image$(RESET)"
	docker build -t $(CI_IMAGE_NAME):$(IMAGE_TAG) .

docker/push-ci:
	$(MAKE) docker/build-ci
	@echo "$(INFO_COLOR)==> $(RESET)$(BOLD)Push Docker image$(RESET)"
	docker push $(CI_IMAGE_NAME):$(IMAGE_TAG)
