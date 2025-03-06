build:
	docker build -t treasure_hunt_tracker .

setup_ecr:
	aws ecr create-repository --repository-name=bwebster/treasure_hunt_tracker --region=us-east-1

login_ecr:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 667830286566.dkr.ecr.us-east-1.amazonaws.com/bwebster/treasure_hunt_tracker

push: login_ecr
	docker tag treasure_hunt_tracker:latest 667830286566.dkr.ecr.us-east-1.amazonaws.com/bwebster/treasure_hunt_tracker:latest && \
	docker push 667830286566.dkr.ecr.us-east-1.amazonaws.com/bwebster/treasure_hunt_tracker:latest
