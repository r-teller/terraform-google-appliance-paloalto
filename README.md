# Palo Alto Appliance on GCP
This deploys a single Palo Alto applicance firewall on Google Compute Engine.


## Install
Check out Github repository to your local workstation:
```
git clone git@github.com:r-teller/terraform-google-appliance-paloalto.git
```

Initialize the Terraform configuration in the working directory:
```
terraform init
```

## Usage
You will find various examples that can be deployed in the `examples/` directory. 
Start of by updating `project_id` in the example directory of your choice.

Plug in your networks into `examples/$example_dir/main.tf` or create new networks according to that file:

```
# VPC networks
gcloud compute networks create ngfw-poc-prod-vpc-outside-global \
    --bgp-routing-mode=global \
    --subnet-mode=custom
gcloud compute networks create ngfw-poc-prod-vpc-mgmt-global \
    --bgp-routing-mode=global \
    --subnet-mode=custom
gcloud compute networks create ngfw-poc-prod-vpc-inside-global \
    --bgp-routing-mode=global \
    --subnet-mode=custom
gcloud compute networks create ngfw-poc-prod-vpc-dmz-global \
    --bgp-routing-mode=global \
    --subnet-mode=custom

# Subnetworks
gcloud compute networks subnets create ngfw-poc-prod-outside-global-subnet-10-10-0-0-24  \
    --network=ngfw-poc-prod-vpc-outside-global \
    --range=10.10.0.0/24 \
    --region=us-central1
gcloud compute networks subnets create ngfw-poc-prod-mgmt-global-subnet-10-255-0-0-24  \
    --network=ngfw-poc-prod-vpc-mgmt-global \
    --range=10.255.0.0/24 \
    --region=us-central1
gcloud compute networks subnets create ngfw-poc-prod-inside-global-subnet-172-16-0-0-24  \
    --network=ngfw-poc-prod-vpc-inside-global \
    --range=172.16.0.0/24 \
    --region=us-central1
gcloud compute networks subnets create ngfw-poc-prod-dmz-global-subnet-192-168-0-0-24  \
    --network=ngfw-poc-prod-vpc-dmz-global \
    --range=192.168.0.0/24 \
    --region=us-central1
```

Update the SSH public key in `ssh_key.pub` to your SSH public key. This key will be used for logging into the Palo Alto appliances.

Run terraform plan
```
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.palo_alto_usc1_41.google_compute_address.external_address["0"] will be created
  + resource "google_compute_address" "external_address" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "ngfw-poc-prod-vpc-outside-global-palo-alto-usc1-41-ext"
      + network_tier       = "PREMIUM"
      + project            = "project_name"
      + purpose            = (known after apply)
      + region             = "us-central1"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

... output omitted ..

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

If plan is successful and looks good to you, run `terraform apply` to deploy this configuration.

## Contributing

PRs accepted.

## License

MIT © Richard McRichface