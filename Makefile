.PHONY: all init fmt validate test docs clean

all: init fmt validate test

init:
	terraform init

fmt:
	terraform fmt -recursive

validate:
	terraform validate
	tflint
	checkov -d .
	tfsec .

test:
	cd test/integration && go test -v ./...
	terraform test

docs:
	terraform-docs markdown table --output-file README.md .

clean:
	rm -rf .terraform
	find . -type f -name "*.tfstate" -delete
	find . -type f -name "*.tfstate.backup" -delete
	find . -type f -name ".terraform.lock.hcl" -delete

security-scan:
	tfsec .
	checkov -d .
	gitleaks detect --source . --verbose

pre-commit:
	pre-commit run --all-files
