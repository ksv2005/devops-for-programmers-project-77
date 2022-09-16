init:
	terraform -chdir=terraform init

apply:
	terraform -chdir=terraform apply

plan:
	terraform -chdir=terraform plan

destroy:
	terraform -chdir=terraform destroy

install:
	ansible-galaxy collection install -r ansible/requirements.yml

deploy:
	ansible-playbook -i ansible/inventory.ini -v --vault-password-file ansible/vault-password ansible/playbook.yml

encrypt:
	ansible-vault encrypt --vault-password-file ansible/vault-password ansible/group_vars/webservers/vault.yml

decrypt:
	ansible-vault decrypt --vault-password-file ansible/vault-password ansible/group_vars/webservers/vault.yml
