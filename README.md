# Terraform sample

This example was created based on "eu-south-1" region and "eu-south-1c" availability zone.
If you need to change the location, you can include it on the terraform apply comand

```ssh
terraform apply -var region=us-east-2 -var availability_zone=us-east-2c <OTHERS VARIABLES>
```

##### For the example, those are the variables used and that can be changed on terminal.
`region, availability_zone, subnet_prefix, access_key, secret_key, ami, key_name, instance_type`

# Usage
```ssh
terraform init
terraform apply --auto-approve
```