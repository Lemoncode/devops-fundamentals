# EC2 Terraform

## Using this repo

Each cloud provider needs its own configuration. To use it quickly with AWS, install visual studio code and dev containers extension. Then just reopen in container.

Also you will need AWS user account with enough privileges to create the desired resources. The easiest way to accomplish this, is by creating a user with `administrator role`. In order to access instances, you will need as well a valid key pair on the region that you are deploying the instance.

Notice as well that the user data scrpts are aligned with Amozon Linux 2. You will need provide and AMI that fits into this OS. Recall that AMIs change by region. On `eu-west-3` (Paris), the detail info its as follows:

```
Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type

ami-0cb46d5e428a134e3 (64-bit (x86)) / ami-016d14ff69436351f (64-bit (Arm))
Amazon Linux 2 comes with five years support. It provides Linux kernel 5.10 tuned for optimal performance on Amazon EC2, systemd 219, GCC 7.3, Glibc 2.26, Binutils 2.29.1, and the latest software packages through extras. This AMI is the successor of the Amazon Linux AMI that is now under maintenance only mode and has been removed from this wizard.
```

It's important that you also take care on how are you going to run containers in order to choose the AMI. Recall, unless you do muti architecture builds, your containers will only run on the same architecture as you built them.

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

