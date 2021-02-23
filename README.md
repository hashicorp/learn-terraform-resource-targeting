# Learn Terraform Cloud Run Triggers

Learn what Terraform Cloud Run Triggers are and when to use them.

Follow along with the [Learn guide](https://learn.hashicorp.com/terraform/tfc/tfc_run_triggers) at HashiCorp Learn.

This repository implements a VPC and a load balancer, meant to be used in
conjunction with the application configured in the [application
repository](https://github.com/hashicorp/learn-terraform-run-triggers-application).

# Steps

1. Check out config: 
1. Initialize the config: `terraform init`
1. Apply the config: `terraform apply`
1. In another tab, watch the results of GET requests to the LB: `while :; do curl $(terraform output -raw public_dns_name); sleep 2; done`
  ```
  Connected to instance #1
  Connected to instance #0
  Connected to instance #1
  Connected to instance #0
  ```
1. Update the instance count: Add a `terraform.tfvars` with the contents:
    ```
    instance_count = 5
    ```
1. Plan the change: `terraform plan`
1. Notice that there are three new instances in the plan, and three
   corresponding elb attachments.
1. Each change in the plan is preceded by the ID of the resource that will be
   changing.
1. Create the instances, but not the ELB attachments
1. Run `terraform apply -target=aws_instance.app` to create the instaances
1. Check the other tab...we're still only connecting to two instances...
  ```
  Connected to instance #0
  Connected to instance #1
  Connected to instance #0
  Connected to instance #1
  ```
1. Apply the rest of the change: `terraform apply`.
1. Check the other tab again...
  ```
  Connected to instance #1
  Connected to instance #3
  Connected to instance #4
  Connected to instance #2
  Connected to instance #0
  Connected to instance #1
  ```
1. Reduce the number of instances to three in `terraform.tfvars`
  ```
  instance_count = 3
  ```
1. Plan the change: `terraform plan`.
1. Apply the change, targeting a single ELB attachment: `terraform apply -target=module.elb_http.module.elb_attachment.aws_elb_attachment.this[4]`
