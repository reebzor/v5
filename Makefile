VERSION := $(shell cat version.txt)
APP := dotcom
CONTAINER := $(APP)-$(VERSION)
REGISTRY := 766004487305.dkr.ecr.us-east-1.amazonaws.com
REGISTRY_NS := tomreeb

REMOTE_PATH := $(REGISTRY)/$(REGISTRY_NS)/$(APP)
REMOTE_TAG := $(REMOTE_PATH):$(VERSION)
LATEST_TAG := $(REMOTE_PATH):latest

PORTS = -p 80:80

.phony: all build build-nc clean run test release

login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(REGISTRY)

build: lint
	docker build -t $(APP):$(VERSION) --rm .

build-nc: lint
	docker build --no-cache -t $(APP):$(VERSION) --rm .

run: build
	docker run --rm $(PORTS) $(VOLUMES) $(APP):$(VERSION)

shell: build
	docker run --rm -it $(PORTS) $(VOLUMES) $(APP):$(VERSION) /bin/ash

rm:
	docker rmi $(APP):$(VERSION)

clean:
	docker kill $(CONTAINER) || true
	docker rm $(CONTAINER) || true

lint:
	docker run --rm --privileged -v `pwd`:/root/ projectatomic/dockerfile-lint dockerfile_lint

test: clean build
	dgoss run -d --name $(CONTAINER) $(PORTS) $(VOLUMES) -t $(APP):$(VERSION)

dgoss: clean build
	dgoss edit -d --name $(CONTAINER) $(PORTS) $(VOLUMES) -t $(APP):$(VERSION)

release: login build
	docker tag $(APP):$(VERSION) $(REMOTE_TAG)
	docker tag $(APP):$(VERSION) $(LATEST_TAG)
	docker push $(REMOTE_TAG)
	docker push $(LATEST_TAG)
	git tag -a $(VERSION) -m "Source for: $(REMOTE_TAG) - $(git log -1 --pretty=%B | head -n 1)" -f
	git push origin $(VERSION)

plan:
	terraform init tf/
	terraform plan tf/

deploy: plan
	terraform apply tf/