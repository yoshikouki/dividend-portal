setup:
	docker compose build
	docker compose run --rm app bin/setup

lint:
	@bundle exec rubocop

lint-a:
	@bundle exec rubocop -A

docker/connect:
	@docker compose exec app bash

docker/lint:
	@docker compose run --rm app bundle exec rubocop

docker/lint-a:
	@docker compose run --rm app bundle exec rubocop -A
