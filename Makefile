REGISTRY := burkewebster
IMAGE := treasure_hunt_tracker

prune_old:
	@echo "Fetching list of image tags..."
	@tags=$$(doctl registry repository list-tags $(IMAGE) --format Tag --no-header | grep -v '^latest$$'); \
	if [ -z "$$tags" ]; then \
		echo "No old images to delete."; \
	else \
		echo "Deleting old images..."; \
		for tag in $$tags; do \
			echo "Deleting tag: $$tag"; \
			doctl registry repository delete-manifest $(IMAGE):$$tag --force; \
		done; \
		echo "Starting garbage collection..."; \
		doctl registry garbage-collection start --force; \
	fi

build:
	docker build -t registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest .

buildnc:
	docker build --no-cache -t registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest .

login:
	doctl registry login

push: login
	docker push registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest

deploy:
	cd infra && terraform plan && terraform apply

# Run from host system
dind_build:
	docker compose -f docker-compose.dind.yaml up -d
	docker compose -f docker-compose.dind.yaml exec dind sh -c "apk add make curl doctl && cd /rails && make build push"
