setup:
	docker compose build
	docker compose run --rm app bin/setup

lint:
	@bundle exec rubocop

lint-a:
	@bundle exec rubocop -A

test:
	@bundle exec rspec

docker/connect:
	@docker compose exec app bash

docker/lint:
	@docker compose run --rm app make lint

docker/lint-a:
	@docker compose run --rm app make lint-a

docker/test:
	@docker compose run --rm app make test
