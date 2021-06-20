IMAGE_BASE_PATH =
CI_IMAGE_NAME := $(IMAGE_BASE_PATH)yoshikouki/dividend-portal
IMAGE_TAG = latest

INFO_COLOR=\033[1;34m
RESET=\033[0m
BOLD=\033[1m

USER_NAME := $(shell git config --get user.name)

setup:
	docker compose build
	docker compose run --rm app bin/setup

lint:
	@bundle exec rubocop

lint-a:
	@bundle exec rubocop -A

test:
	@bundle exec rspec $(P)

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
