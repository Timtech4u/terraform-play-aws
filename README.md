# Terraform Module to provision EKS Cluster

## Pre-requisites
Install the following:
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads.html)


After installing the AWS CLI. Configure it to use your credentials.
This enables Terraform access to the configuration file and performs operations on your behalf with these security credentials.

```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: <YOUR_AWS_REGION>
```
 
## Setup Keybase Key
- [Setup a Keybase Account](https://keybase.io)
- [Install Keybase CLI](https://keybase.io/docs/the_app/install_linux)
- Login to Keybase CLI using: `keybase login`
- Setup a Keybase key `keybase pgp gen`

Ensure to set the following within Terraform
```
  pgp_key = "keybase:<username>"
```

Where _<username>_ is your Keybase account username


To get the decrypted password, you can run the following `terraform apply`
```shell
$ terraform output iam_password | base64 --decode | keybase pgp decrypt"
```


After you've done this, initalize your Terraform workspace with the following command:

```shell
$ terraform init
```

Execute the following to see what the infrastructure looks like:

```shell
$ terraform plan
```


Then, provision your EKS cluster by running `terraform apply`. This will take approximately 10 minutes.

```shell
$ terraform apply
```
