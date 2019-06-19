PATH := node_modules/.bin:ops/bin:$(PATH)
SHA := $(shell git rev-parse --verify HEAD)

.PHONY:

configure: .PHONY
	configure-project
	terraform init ops/terraform