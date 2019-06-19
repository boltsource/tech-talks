PATH := node_modules/.bin:ops/bin:$(PATH)
SHA := $(shell git rev-parse --verify HEAD)

.PHONY:

configure: .PHONY
	configure-project
	terraform init ops/terraform

infra: .PHONY
	terraform apply ops/terraform
	gcloud container clusters get-credentials main-cluster

dev:
	nodemon

clean: .PHONY
	rm -rf dist

build: clean
	tsc

package: build
	docker build -t graphql-api:latest .
	docker tag graphql-api:latest us.gcr.io/$(PROJECT_ID)/graphql-api:latest

deploy: package
	docker push us.gcr.io/$(PROJECT_ID)/graphql-api:latest
	kubectl apply -f kube.yaml

tunnel: .PHONY
	tunnel

ngrok: .PHONY
	ngrok http -subdomain boltsource 8080