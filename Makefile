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
	docker build --platform=linux/amd64 -t registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest .

buildnc:
	docker build --no-cache --platform=linux/amd64 -t registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest .

login:
	doctl registry login

push: login
	docker push registry.digitalocean.com/burkewebster/treasure_hunt_tracker:latest

deploy:
	cd infra && terraform plan && terraform apply
