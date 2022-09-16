init:
	terraform -chdir=terraform init

apply:
	terraform -chdir=terraform apply

plan:
	terraform -chdir=terraform plan

destroy:
	terraform -chdir=terraform destroy
