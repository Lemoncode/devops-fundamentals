# EC2 Terraform

## Using this repo

Each cloud provider needs its own configuration. To use it quickly with AWS, install visual studio code and dev containers extension. Then just reopen in container.

Also you will need AWS user account with enough privileges to create the desired resources. The easiest way to accomplish this, is by creating a user with `administrator role`. In order to access instances, you will need as well a valid key pair on the region that you are deploying the instance.

## Running Terraform

### Setup Credentials

```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
```

### Kick Off

```bash
terraform init
terraform validate
terraform plan -out infra.tfplan
terraform apply "infra.tfplan"
```

### Clean Up

```bash
terraform destroy
```

