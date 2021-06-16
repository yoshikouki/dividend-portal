setup:
	docker compose build
	docker compose run --rm app bin/setup
