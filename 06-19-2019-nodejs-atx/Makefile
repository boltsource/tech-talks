PATH := node_modules/.bin:ops/bin:$(PATH)
SHA := $(shell git rev-parse --verify HEAD)

.PHONY:

configure: .PHONY
	configure-project
	terraform init ops/terraform

dev:
	nodemon

clean: .PHONY
	rm -rf dist

build: clean
	tsc

package: build
	docker build -t $(SHA) .
	echo $(SHA)

deploy: package
	docker push us.gcr.io/$(PROJECT_ID)/graphql-api:$(SHA)
	SHA=$(SHA) terraform apply ops/terraform