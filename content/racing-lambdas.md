+++
title = "Racing Lambdas"
date = 2019-11-27
draft = false

[taxonomies]
categories = ["Rust", "Terraform", "AWS", "Lambda", "IAC", "Terraform", "Graviton2"]
tags = ["lambda build", "performance comparison", "x86 v arm"]
+++

## Introduction

Let's begin this journey with the end in mind. The final objective is to compare the performance of a Rust lambda running on X86_64 and Amazon's Graviton2. Along the way we need to:

- decide what the test lambda will do and how it will be called
- implement the infrastructure on AWS to support the lambda
- develop the rust code to execute in the lambda
- compile the code to run on and x86_64 architecture
- create a lambda to execute the x86_64 code
- compile the code to run on a Graviton2 architecture
- create a lambda to execute the Graviton2 code
- Script a test to call the lambdas and measure the cost
<!-- more -->

The comparison will be based on the lambda execution reports.

>REPORT RequestId: d17498cb-375c-4cf6-8b43-a5893b9c2713 Duration: 1258.00 ms    **Billed Duration:** 1324 ms    Memory Size: 128 MB **Max Memory Used**: 49 MB **Init Duration**: 65.49 ms

## What does the lambda do

The test needs to be simple enough that it can be implemented as part of this series and substantial enough that it provides a reasonable test. The lambda application that I have selected is processing a website contact form.

The scope includes the lambda function and infrastructure called by the function.

The scope excludes the front end application and gateway.

We will mock the API gateway to provide the data to call the lambda function and provide AWS infrastructure to support the immediate calls by the function.

The lambda function will:

- take as input Name, Phone, Email, Message and Captcha Response Token.
- retrieve the captcha service secret from the parameter store (Systems Manager)
- validate the Captcha Response Token
- send a notification to the website owner using SES
- send an acknowledgement to the visitor using SES
- store the form data using SNS and SQS
- return success when notification and acknowledgement are successful
- return an error if validation, notification or acknowledgement fail

If the acknowledgment or notification fails we want the visitor to retry. The loss of the record is not critical (as we will have the notification) and not a reason to force the visitor to enter their details again and get two (or more) acknowledgements.

## Supporting Cloud Infrastructure

We will use Terraform Infrastructure as Code to build the supporting services. I prefer Terraform over Cloud Foundation on the principle of selecting the more general tool. General tools provide better return on learning as they have wider applicability (unless you are happy to lock into a walled garden).

Let's start by setting up a project to contain the code that we create. Let's call it `racing`.

``` zsh
mkdir racing
```

As a matter of good practice initialise it for git. Eventually we may use GitHub actions to automate the updates to code and infrastructure.

```zsh
cd racing
racing> git init
```

### Terraform Setup

Terraform uses APIs to apply the changes specified in your code and stores a representation of the current state of the infrastructure. The stored state allows Terraform to determine what has changed and apply only those changes required to align the state with the code. This technique also serves to "correct" any changes that might have been made outside of terraform and align them with your code as the specification of record for the infrastructure.

As we may want to automate the application of changes as lambda code is updated it is best to store the state information remotely. For remote storage we will use an Amazon S3 bucket.

So, to follow along, you will need the following:

- The [Terraform CLI][url-terraform-cli] (v1.0+) installed.
- The [AWS CLI][url-aws-cli] installed.
- [An AWS account][url-aws-account].
- Your AWS credentials. You can [create a new Access Key on this page][url-access-key].

[url-terraform-cli]: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
[url-aws-cli]: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
[url-aws-account]: https://aws.amazon.com/free/
[url-access-key]: https://console.aws.amazon.com/iam/home?#/security_credentials

#### Setup Terraform and lock in versions for Terraform and Providers

Create a directory to contain the Terraform modules and code files.

``` zsh
racing> mkdir iac
```

The first module will contains the shared configurations.

``` zsh
racing> cd iac
racing/iac> mkdir _shared
```

Create a Terraform file. All `.tf` files in a directory will be loaded to compile the code for the module. This allows us to organise the code by function in separate files. The setup of the versions of terraform and the providers will be saved in a file called `versions.tf`.

Specify the versions for Terraform and the the AWS provider and the name of the AWS provider.

``` terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.61"
    }
  }
  required_version = ">= 1.0"
}
```

Version 3.61 of the AWS provider is required to support the configuration of architecture on a lambda function.

### S3

We need to create an S3 bucket to store the remote state for our infrastructure. We also want to control the configuration of this bucket using Terraform. Sounds like a bit of a chicken and egg conundrum.

Let's start by creating the bucket.

#### Create S3 Bucket to Store Remote State

Start a new module to build the remote-store bucket.

``` zsh
mkdir remote-bucket
```

Create `main.tf` to import the shared module.

``` terraform
module "shared" {
  source = "..\_shared"
}
```

Create a `resources.tf` to specify the resources that this module will create.

``` terraform
resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "racing-iac-state"
  acl    = "private"

  tags = {
    Name    = "Racing Lambdas Terraform Remote State"
    Project = "racing-lambdas"
  }
}
```

Bucket names need to be unique within a partition and can consist of up to 63 lowercase, numbers dots (.) and hyphens. The must begin and end with a letter or number. For a full list of rules you can find the AWS documentation [here][url-aws-bucket-naming].

[url-aws-bucket-naming]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

You can check the validity of your terraform code as you go with with the command `terraform validate`. You will need to init the module first include the shared code and setup the provider.

``` zsh
racing/iac/remote-bucket❯ terraform init
Initializing modules...
- shared in ../_shared

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 3.61.0"...
- Installing hashicorp/aws v3.63.0...
- Installed hashicorp/aws v3.63.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

racing/iac/remote-bucket❯ terraform validate
Success! The configuration is valid.
```

This ensures that your code looks correct; its not a guarantee that it will execute :smiley:.

`terraform plan` runs the scenario and reports on the changes that will be made should the current configuration be applied.

``` zsh
racing/iac/remote-bucket> terraform plan
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value:
```

The AWS provider needs to know the region where we plan to build the infrastructure. We haven't initialised the provider with the default value required in this module.

We can create a `variables.tf` file to declare and (optionally) initialise variables.

``` terraform
variable "region" {
  type    = string
  default = "eu-west-1"
}
```

And initialize the provider in `main.tf`.

``` terraform
provider "aws" {
  region = var.region
}
```

Now, `terraform plan` produces a plan without prompting for any additional inputs.

``` zsh
racing/iac/remote_bucket❯ terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.tf_remote_state will be created
  + resource "aws_s3_bucket" "tf_remote_state" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "racing-iac-state"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name"    = "Racing Lambdas Terraform Remote State"
          + "Project" = "racing-lambdas"
        }
      + tags_all                    = {
          + "Name"    = "Racing Lambdas Terraform Remote State"
          + "Project" = "racing-lambdas"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

We now have a plan to create the S3 bucket on AWS. Lets apply the change.

``` zsh
racing/iac/remote-bucket> terraform apply
```

Terraform generates the plan and requests confirmation to apply.

``` zsh
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.tf_remote_state will be created
  + resource "aws_s3_bucket" "tf_remote_state" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "racing-iac-state"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name"    = "Racing Lambdas Terraform Remote State"
          + "Project" = "racing-lambdas"
        }
      + tags_all                    = {
          + "Name"    = "Racing Lambdas Terraform Remote State"
          + "Project" = "racing-lambdas"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Once confirmed the change is executed and resources created listed.

``` zsh
  Enter a value: yes

aws_s3_bucket.tf_remote_state: Creating...
aws_s3_bucket.tf_remote_state: Creation complete after 4s [id=racing-iac-state]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### Setting the Region as a Shared variable

The region variable is one that we will use in all (or most) configurations and therefore we should set this default in the shared module. Move the `variable.tf` file to the `_shared` directory.

``` zsh
racing/iac> mv remote_bucket/variables.tf _shared/variables.tf
```

Variables are scoped to the module in which they are defined and used. We need to capture the value of the region variable as an output from the module so that we can share it with other modules. Create the file `outputs.tf` in the `_shared` with the following configuration.

``` terraform
output "region" {
  value = var.region
}
```

We can now use the region value by updating `main.tf` in `remote_bucket`.

``` terraform
provider "aws" {
  region = module.shared.region
}
```

The backend might seem a good candidate for the shared module, however terraform requires that the backend is defined and configured in the root module. This allows us to specify different backend files (or backend locations) for the different sets of configured services.

#### Creating the backend configuration

We can not use variables to supply the values for the backend. The values for bucket and region will be consistent across all configurations. The value for the key we will supply and customised for each root file.

``` terraform
provider "aws" {
  region = module.shared.remote_region
}

terraform {
  backend "s3" {
    key    = "remote-bucket"
  }
}
````

We create a configuration `racing\iac\remote.config` file for the bucket and region values.

``` terraform
bucket = "racing-iac-state"
region = "eu-west-1"
```

Now that we have changed the backend configuration we need to run `terraform init` again.

``` zsh
racing/iac/remote-bucket❯ terraform init --backend-config=../remote.config
Initializing modules...

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value:
```

Terraform requests confirmation to migrate the state from local to remote.

```zsh
  Enter a value: yes


Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.63.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

Running `terraform plan` confirms that all is as it should be.

``` zsh
❯ terraform plan
aws_s3_bucket.tf_remote_state: Refreshing state... [id=racing-iac-state]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
```

We can confirm that the remote-bucket state file exists in the bucket by listing it with the AWS CLI.

``` zsh
racing/iac/remote-bucket❯ aws s3 ls racing-iac-state
2021-10-18 13:21:40       1901 remote-bucket
```

#### Safety first - versioning the bucket

Terraform recommends that a remote s3 bucket has `versioning` enabled. This allows for recovery if the data in the bucket is overwritten by a user. To limit the storage costs of multiple versions we will implement a `lifecycle_rule` to delete the copies after fourteen days.

``` terraform
resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "racing-iac-state"
  acl    = "private"

  tags = {
    Name    = "Racing Lambdas Terraform Remote State"
    Project = "racing-lambdas"
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 14
    }

  }
}
```

Let's `terraform apply` to get a plan and apply if it looks good.

``` zsh
racing/iac/remote-bucket> terraform apply
aws_s3_bucket.tf_remote_state: Refreshing state... [id=racing-iac-state]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_s3_bucket.tf_remote_state will be updated in-place
  ~ resource "aws_s3_bucket" "tf_remote_state" {
        id                          = "racing-iac-state"
        tags                        = {
            "Name"    = "Racing Lambdas Terraform Remote State"
            "Project" = "racing-lambdas"
        }
        # (10 unchanged attributes hidden)

      + lifecycle_rule {
          + enabled = true

          + noncurrent_version_expiration {
              + days = 14
            }
        }

      ~ versioning {
          ~ enabled    = false -> true
            # (1 unchanged attribute hidden)
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:

```

We see in the plan that we are changing 1 resource by updating the versioning
configuration from false to true and adding an active lifecycle_rule as we
specified in the terraform file.
All looks good so we type `yes` to approve and have the configuration change
applied.

``` zsh
  Enter a value: yes

aws_s3_bucket.tf_remote_state: Modifying... [id=racing-iac-state]
aws_s3_bucket.tf_remote_state: Modifications complete after 3s
  [id=racing-iac-state]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
racing/iac/remote-bucket❯ aws s3 ls racing-iac-state
2021-10-18 14:04:12       2428 remote-bucket
```

The new configuration information has increased the size of the state file in the bucket and as you can see we now have two versions of the file.

``` zsh
aws s3api \
    list-object-versions \
    --bucket racing-iac-state \
    --prefix remote-bucket \
    --output json \
    | jq '[.Versions[] | {Key: .Key, IsLatest: .IsLatest, LastModified: .LastModified, Size: .Size}]'
[
  {
    "Key": "remote-bucket",
    "IsLatest": true,
    "LastModified": "2021-10-18T14:04:12+00:00",
    "Size": 2428
  },
  {
    "Key": "remote-bucket",
    "IsLatest": false,
    "LastModified": "2021-10-18T13:21:40+00:00",
    "Size": 1901
  }
]
```

> **Note** I am using [jq][url-jq] to filter the fields returned from the AWS CLI command.

[url-jq]: https://stedolan.github.io/jq

### Systems Manager

The form submission will be protected from bots by [hcaptcha][hcaptcha-url]. Captchas work by presenting a visitor with a test to confirm that they are not a bot. Captcha implementations using a third party service (such as Hcaptcha or Recaptcha) provide the custom test and on successful validation provide a response token. The response token should be sent with the data to the processor so that the backend can validate that the data has been received from a client which passed a captcha test. The backend sends the response token with a secret key to the third party for validation.

[hcaptcha-url]: https://www.hcaptcha.com/

It is not good practice to store secret keys in the application code (and on the source control service). On AWS we can store secrets in the Systems Manager Parameter Store or on Secrets Manager. For this application the additional features (and cost) of Secret Manager are not required, so we will use the Parameter Store. A good comparison can be found on [Awesome Cloud][awesome-cloud-url].

[awesome-cloud-url]: https://medium.com/awesome-cloud/aws-difference-between-secrets-manager-and-parameter-store-systems-manager-f02686604eae

#### Store the captcha secret securely in the parameter store

We start with a new main configuration module called `secret`.

``` zsh
racing/iac> mkdir secret
racing/iac> cd secret
```

Copy `main.tf` from `remote_bucket` and amend the backend key so that we save the `secret` module state to a different file.

``` terraform
module "shared" {
  source = "../_shared"
}

provider "aws" {
  region = module.shared.region
}

terraform {
  backend "s3" {
    key = "secret"
  }
}
```

Create the resource to configure the parameter in the parameter store.

``` terraform
resource "aws_ssm_parameter" "captcha_secret" {
  name  = "/racing/captcha/secret"
  type  = "SecureString"
  value = var.secret
}
```

The name must begin with a '/' so that it is fully qualified. Prefixes can be used to structure the parameters. In this example the `secret` parameter is configured for the `captcha` service in the `racing` application. The AWS documentation [here][url-aws-parameters] provides more details on the requirements.

[url-aws-parameters]: https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-create.html

The secret will be provided in a variable as we do not want to enter this data into a code file that will be stored and maintained in source control.

``` terraform
variable "secret" {
  type        = string
  description = "The secret string to access captcha service and validate the
  response token supplied by the client"
}
```

Lets see what the plan looks like.

``` zsh
racing/iac/secret❯ terraform plan
var.secret
  The secret string to access captcha service and validate
  the response token supplied by the client
  Enter a value: secret


Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ssm_parameter.captcha_secret will be created
  + resource "aws_ssm_parameter" "captcha_secret" {
      + arn       = (known after apply)
      + data_type = (known after apply)
      + id        = (known after apply)
      + key_id    = (known after apply)
      + name      = "/racing/captcha/secret"
      + tags_all  = (known after apply)
      + tier      = "Standard"
      + type      = "SecureString"
      + value     = (sensitive value)
      + version   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

As expected on the bottom line, its one resource to add. As we defined a variable with no default value, when terraform prompts for value. I have entered 'secret' here. As a security measure terraform does not output value in the plan; instead it is listed as `(sensitive value)`. As plans may be saved and stored this protects against sensitive values (such as secrets) being recorded in saved plan documents.

Lets see what happens when we apply.

``` zsh
racing/iac/secret❯ terraform apply
var.secret
  The secret string to access captcha service and validate the response token
  supplied by the client

  Enter a value: hidemeplease


Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ssm_parameter.captcha_secret will be created
  + resource "aws_ssm_parameter" "captcha_secret" {
      + arn       = (known after apply)
      + data_type = (known after apply)
      + id        = (known after apply)
      + key_id    = (known after apply)
      + name      = "/racing/captcha/secret"
      + tags_all  = (known after apply)
      + tier      = "Standard"
      + type      = "SecureString"
      + value     = (sensitive value)
      + version   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_ssm_parameter.captcha_secret: Creating...
aws_ssm_parameter.captcha_secret: Creation complete after 1s
    [id=/racing/captcha/secret]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

We have added a new resource to AWS and should have a record of this configuration in the remote state bucket.

``` zsh
racing/iac/secret❯ aws s3 ls racing-iac-state
2021-10-18 14:04:12       2428 remote-bucket
2021-10-19 15:31:26       1048 secret
```

Great! We have a new file in the bucket. I wonder what is in it?

``` zsh
❯ aws s3 cp s3://racing-iac-state/secret secret
download: s3://racing-iac-state/secret to ./secret
❯ cat secret | grep hidemeplease
            "value": "hidemeplease",
```

Interesting, the state file contains in clear text the string that is encrypted in the parameter store. That means that our bucket contains sensitive data. We should encrypt it at rest.

#### Encrypt the remote state data bucket at rest

Update the s3 bucket resource to encrypt the objects at rest. All traffic on s3 is encrypted with TLS ensuring that our sensitive data will be encrypted in motion and at rest.

Create an AWS KMS key to encrypt the bucket.

``` terraform
resource "aws_kms_key" "bucket" {
  description             = "Key to encrypt terraform remote state store"
  deletion_window_in_days = 10
}
```

The deletion window ensures that the encryption key resource is deleted ten days after the related resources have been destroyed as its no longer required.

Configure the encryption rule on the bucket.

``` terraform
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
```

We create a key so that the encryption key is under the control of the account. If not the bucket will be encrypted using the default aws/s3 AWS KMS master key.

```zsh
racing/iac/remote_bucket❯ terraform apply
aws_s3_bucket.tf_remote_state: Refreshing state... [id=racing-iac-state]

Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_kms_key.bucket will be created
  + resource "aws_kms_key" "bucket" {
      + arn                                = (known after apply)
      + bypass_policy_lockout_safety_check = false
      + customer_master_key_spec           = "SYMMETRIC_DEFAULT"
      + deletion_window_in_days            = 10
      + description                        = "Key to encrypt terraform remote state store"
      + enable_key_rotation                = false
      + id                                 = (known after apply)
      + is_enabled                         = true
      + key_id                             = (known after apply)
      + key_usage                          = "ENCRYPT_DECRYPT"
      + policy                             = (known after apply)
      + tags_all                           = (known after apply)
    }

  # aws_s3_bucket.tf_remote_state will be updated in-place
  ~ resource "aws_s3_bucket" "tf_remote_state" {
        id                          = "racing-iac-state"
        tags                        = {
            "Name"    = "Racing Lambdas Terraform Remote State"
            "Project" = "racing-lambdas"
        }
        # (10 unchanged attributes hidden)


      + server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + kms_master_key_id = (known after apply)
                  + sse_algorithm     = "aws:kms"
                }
            }
        }

        # (2 unchanged blocks hidden)
    }

Plan: 1 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:

```

Terraform will add a new resource for the aws/kms key and change the bucket resource to include the encryption rule using the key.

``` zsh
  Enter a value: yes

aws_kms_key.bucket: Creating...
aws_kms_key.bucket: Creation complete after 1s [id=56790fee-1645-4648-8054-e7466dc98f6f]
aws_s3_bucket.tf_remote_state: Modifying... [id=racing-iac-state]
aws_s3_bucket.tf_remote_state: Modifications complete after 3s [id=racing-iac-state]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

The bucket is now encrypted so our secret is safe.

#### Setting the test secret key

hCaptcha provides a set of test keys in their [developer guide][url-test-keys]. We need to set our secret key accordingly in the parameter store.

[url-test-keys]: https://docs.hcaptcha.com/#test-key-set-publisher-account

Terraform variables can be set in a number of ways:

1. when the variable is created
2. when prompted during an interactive run
3. in a tfvars file
4. in an environment variable

Options 1 and 3 are not viable for a secret value. Typing in the value during an interactive run is fine for testing, but ultimately we will want to automate the changes.

We will demonstrate option 4.

``` zsh
racing/iac/secret❯ TF_VAR_secret=0x0000000000000000000000000000000000000000 \
  terraform plan -out=planned
aws_ssm_parameter.captcha_secret: Refreshing state... [id=/racing/captcha/secret]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_ssm_parameter.captcha_secret will be updated in-place
  ~ resource "aws_ssm_parameter" "captcha_secret" {
        id        = "/racing/captcha/secret"
        name      = "/racing/captcha/secret"
        tags      = {}
      ~ value     = (sensitive value)
        # (7 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────

Saved the plan to: planned

To perform exactly these actions, run the following command to apply:
    terraform apply "planned"
❯ terraform apply planned
aws_ssm_parameter.captcha_secret: Modifying... [id=/racing/captcha/secret]
aws_ssm_parameter.captcha_secret: Modifications complete after 0s
    [id=/racing/captcha/secret]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Be aware of command logging when using this technique to ensure that secrets are not being recorded in logs.

In a CI context set the environment variable using the tools environment management.

### Amazon Simple Email Service

Simple Email Service provides services to send and receive emails. For our purposes we will be sending emails and for testing we will never leave the SES sandbox: we be both the sender and the recipient.

Create the `email_service` module to configure AWS SES and copy `main.tf` from `remote_bucket`.

#### Verified Email address

Amazon SES requires that the email addresses for both sender and receiver are verified for sandbox transactions. In production, only the sender needs to be verified.

``` zsh
racing/iac/secret>cd ..
racing/iac> mkdir email_service && cd email_service
racing/iac/email_service>
```

Update the key to store the remote state date in a file for this module.

``` terraform
module "shared" {
  source = "../_shared"
}

provider "aws" {
  region = module.shared.region
}

terraform {
  backend "s3" {
    key = "email-services"
  }
}
```

Setup the email identity that we will use as sender (and recipient). Replace the email in the following code with an email address that you control.

``` terraform
resource "aws_ses_email_identity" "sandbox_identity" {
  email = "user@example.com"
}
```

Initialise the module as before and apply, review the plan and type `yes` to execute.

``` zsh
racing/iac/email_service❯ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ses_email_identity.sandbox_identity will be created
  + resource "aws_ses_email_identity" "sandbox_identity" {
      + arn   = (known after apply)
      + email = "user@example.com"
      + id    = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_ses_email_identity.sandbox_identity: Creating...
aws_ses_email_identity.sandbox_identity: Creation complete after 1s
  [id=user@example.com]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

You will get an email from AWS to confirm your control the email address that you have registered. You can find more information on the process [here][url-aws-ses-email].

[url-aws-ses-email]: https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-email-addresses-procedure

#### Response templates

Good practice when sending emails is to use a template. A template allows us to change the email content without having to change the code. We will setup two templates for the notification and the acknowledgement.

``` terraform
resource "aws_ses_template" "acknowledgement" {
  name    = "racing_acknowledgement"
  subject = "Thank you for your interest in racing lambdas"
  html    = <<-EOT
  <p>Hi {{name}},</p>
  <br>
  <h2>Thank you for your interest in racing lambdas!</h2>
  <p>Your contact details have been logged.</p>
  EOT
  text    = <<-EOT
  Hi {{name}},

  Thank you for your interest in racing lambdas!
  Your contact details have been logged.
  EOT
}

resource "aws_ses_template" "notification" {
  name    = "racing_notification"
  subject = "Racing lambdas contact"
  html    = <<-EOT
  <p>Contact from racing lambdas:</p>
  <table>
    <tr>
        <td>Name</td>
        <td>{{name}}</td>
    </tr>
    <tr>
        <td>Email</td>
        <td>{{email}}</td>
    </tr>
    <tr>
        <td>Telephone</td>
        <td>{{phone}}</td>
    </tr>
  </table>
  <h3>Message from the visitor</h3>
  <p>{{message}}</p>
  EOT
  text    = <<-EOT
  Contact from racing lambdas:
    Name:       {{name}}
    Email:      {{email}}
    Telephone:  {{phone}}

  Message from the visitor:
  {{message}}
  EOT
}
```

Terraform supports heredoc style strings when configuring large strings. It also supports indented heredoc. The indented heredoc preserves the indentation of the string being set by discarding the indent spaces at the start of each line.

``` zsh
racing/iac/email_service❯ terraform apply
aws_ses_email_identity.sandbox_identity: Refreshing state...
    [id=jrussell@jerus.ie]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ses_template.acknowledgement will be created
  + resource "aws_ses_template" "acknowledgement" {
      + arn     = (known after apply)
      + html    = <<-EOT
            <p>Hi {{name}},</p>
            <br>
            <h2>Thank you for your interest in racing lambdas!</h2>
            <p>Your contact details have been logged.</p>
        EOT
      + id      = (known after apply)
      + name    = "racing_acknowledgement"
      + subject = "Thank you for your interest in racing lambdas"
      + text    = <<-EOT
            Hi {{name}},

            Thank you for your interest in racing lambdas!
            Your contact details have been logged.
        EOT
    }

  # aws_ses_template.notification will be created
  + resource "aws_ses_template" "notification" {
      + arn     = (known after apply)
      + html    = <<-EOT
            <p>Contact from racing lambdas:</p>
            <table>
              <tr>
                  <td>Name</td>
                  <td>{{name}}</td>
              </tr>
              <tr>
                  <td>Email</td>
                  <td>{{email}}</td>
              </tr>
              <tr>
                  <td>Telephone</td>
                  <td>{{phone}}</td>
              </tr>
            </table>
            <h3>Message from the visitor</h3>
            <p>{{message}}</p>
        EOT
      + id      = (known after apply)
      + name    = "racing_notification"
      + subject = "Racing lambdas contact"
      + text    = <<-EOT
            Contact from racing lambdas:
              Name:       {{name}}
              Email:      {{email}}
              Telephone:  {{phone}}

            Message from the visitor:
            {{message}}
        EOT
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_ses_template.notification: Creating...
aws_ses_template.acknowledgement: Creating...
aws_ses_template.acknowledgement: Creation complete after 1s
    [id=racing_acknowledgement]
aws_ses_template.notification: Creation complete after 1s
    [id=racing_notification]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### Push and pull with SNS and SQS

The third action that we want to take with the contact information is to save the contact. Saving the contact information is not critical to returning a successful form submission as we already have the details captured in the notification email. We have a range of options for saving the data including:

- create a file in a bucket
- creating an item in a DynamoDb table
- create a record in a relational database (take your pick!)
- integrating the data with an existing application
- adding the contact to a CRM application

We may want to do one or more of these things. Over time we change how we we do some of them. To separate the form processing and storage we will dispatch the contact data to an AWS SNS topic. One (or more) subscribers to the topic can then process the contact information.

> SNS seems a great idea, perhaps we should just dispatch the validated contact information to SNS and let two email subscribers take care of dispatching the notification and acknowledgement?
> Perhaps, but we want to confirm that the emails have been successfully dispatched before confirming to the visitor that the form has been received and processed. Storing the contact information is not material to the success of form submission. In fact asking the visitor to retry submission of the contact form because we failed to store it will annoy the visitor as:
>
> - they have an acknowledgement
> - the storage issue is not likely to be resolved by retrying
> - the failure is not likely to be in the data submitted
>
> Our lambda controls the actions that are critical to confirming that we have all we need from the visitor and any further processing can be done by subscribers to the notification topic.

The Simple Notification Service will push the messages to all subscribers to a topic. The message is not stored by SNS. If a subscriber is unable to process a message when it is pushed it will be lost. SNS is not guaranteed delivery. To protect our storage processor we place an AWS SQS queue in front of it. Collect and store the messages until they are pulled by the code processing the data.

To store the contact form information then we need:

1. SNS queue for "further form processing" as a flexible dispatch point
2. SQS queue for form storage
3. Service (lambda) to store the information

We will configure 1 and 2 here to provide a solution that is sufficient for our ultimate goal of racing the lambda built on two different architectures.

#### Notification topic

Initialise a new module for the `further` processing activities.

``` zsh
racing/iac❯ mkdir further
racing/iac❯ cp remote_bucket/main.tf further/
racing/iac❯ sed "s/remote-bucket/further/" further/main.tf
module "shared" {
  source = "../_shared"
}

provider "aws" {
  region = module.shared.region
}

terraform {
  backend "s3" {
    key = "further"
  }
}
racing/iac❯ sed -i "s/remote-bucket/further/" further/main.tf
racing/iac❯ cd further
racing/iac/further❯ terraform init --backend-config=../remote.config
Initializing modules...
- shared in ../_shared

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 3.61.0"...
- Installing hashicorp/aws v3.63.0...
- Installed hashicorp/aws v3.63.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Create a topic in the notification services

``` terraform
resource "aws_sns_topic" "further_processing" {
  name = "racing-lambda-further-processing"
}
```

Use terraform apply to create the resources and check that we have a new remote state file stored in the bucket.

``` zsh
racing/iac/further❯ terraform apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_sns_topic.further_processing will be created
  + resource "aws_sns_topic" "further_processing" {
      + arn                         = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "racing-lambda-further-processing"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + tags_all                    = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_sns_topic.further_processing: Creating...
aws_sns_topic.further_processing: Creation complete after 1s
  [id=arn:aws:sns:eu-west-1:{AWS_ACCOUNT}:racing-lambda-further-processing]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
racing/iac/further❯ aws s3 ls racing-iac-state
2021-10-20 11:35:58       3003 email-services
2021-10-20 16:19:41       2439 further
2021-10-19 16:29:48       4220 remote-bucket
2021-10-20 07:13:45       1082 secret
```

> ***Note***
> The AWS Account ID is output by terraform. I have replaced it in the text above as this is sensitive (at lease not for publication in a blogs!).

We have created a topic where we will publish the data collected by the contact form for the Racing Lambdas site.

Consider the data collected on the for: names, contact details and messages. The names and contact details at least are sensitive. In transit it will be encrypted with TLS as all AWS API calls are over https. However, we need to configure encryption at the server side.

``` terraform
resource "aws_kms_key" "sns_topic" {
  description             = "Key to encrypt sns topic on server side"
  deletion_window_in_days = 10
}

resource "aws_sns_topic" "further_processing" {
  name              = "racing-lambda-further-processing"
  kms_master_key_id = aws_kms_key.sns_topic.arn
}
```

We create a customer management key for to encrypt the topic server side and set the key's arn in the resource configuration.

``` zsh
racing/iac/further❯ terraform apply
aws_sns_topic.further_processing: Refreshing state... 
    [id=arn:aws:sns:eu-west-1:{AWS_ACCOUNT}:racing-lambda-further-processing]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply":

  # aws_sns_topic.further_processing has been changed
  ~ resource "aws_sns_topic" "further_processing" {
        id                          = "arn:aws:sns:eu-west-1:{AWS_ACCOUNT}
                                      :racing-lambda-further-processing"
        name                        = "racing-lambda-further-processing"
      + tags                        = {}
        # (6 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the
relevant attributes using ignore_changes,
the following plan may include actions to undo or respond to these changes.

───────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the
following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_kms_key.sns_topic will be created
  + resource "aws_kms_key" "sns_topic" {
      + arn                                = (known after apply)
      + bypass_policy_lockout_safety_check = false
      + customer_master_key_spec           = "SYMMETRIC_DEFAULT"
      + deletion_window_in_days            = 10
      + description                        = "Key to encrypt sns topic on
                                              server side"
      + enable_key_rotation                = false
      + id                                 = (known after apply)
      + is_enabled                         = true
      + key_id                             = (known after apply)
      + key_usage                          = "ENCRYPT_DECRYPT"
      + policy                             = (known after apply)
      + tags_all                           = (known after apply)
    }

  # aws_sns_topic.further_processing will be updated in-place
  ~ resource "aws_sns_topic" "further_processing" {
        id                          = "arn:aws:sns:eu-west-1:{AWS_ACCOUNT}
                                      :racing-lambda-further-processing"
      + kms_master_key_id           = (known after apply)
        name                        = "racing-lambda-further-processing"
        tags                        = {}
        # (6 unchanged attributes hidden)
    }

Plan: 1 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_kms_key.sns_topic: Creating...
aws_kms_key.sns_topic: Creation complete after 1s
    [id=6d63188a-0ee3-49d4-82aa-528eb4f9fcaa]
aws_sns_topic.further_processing: Modifying...
    [id=arn:aws:sns:eu-west-1:{AWS_ACCOUNT}:racing-lambda-further-processing]
aws_sns_topic.further_processing: Modifications complete after 1s
    [id=arn:aws:sns:eu-west-1:{AWS_ACCOUNT}:racing-lambda-further-processing]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

An SNS topic creates a pub-sub message delivery system. The lambda that we will build will be the publisher and as we discussed earlier we may have one or more subscribers. These subscribers may also be applications within our environment (e.g. a lambda to store the contact form data in DynamoDb) or external to our environment (a SaaS based CRM tool tracking our sales leads). The question we need to consider is who can publish and who can subscribe? The terraform output tells us that one of the attributes of the resource is policy which "known after apply". We should take a look and see if the default configuration meets our needs.

``` json
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "arn:aws:sns:eu-west-1:{AWS_ACCOUNT}:racing-lambda-further-processing",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "{AWS_ACCOUNT}"
        }
      }
    }
  ]
}
```

This policy allows anyone on AWS to perform the specified SNS actions on our topic provided that they are owned by the account that owns the topic. This will certainly the case for the publisher and likely the case for the DynamoDb store subscriber as its internal. It would not support an external subscriber.

We can use AWS IAM to configure a role that allows subscription to our SNS topic. The IAM role can enable users from other accounts, federated users or applications to gain access to the topic and permission to subscribe.

``` terraform
resource "aws_iam_role" "subscribe" {
  name = "subscribe-racing-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principle = {
          service = "sqs.amazon.com"
        }
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.racing_lambda_subscriber.arn]
}
```

The `assume_role_policy` sets out the conditions that must be met by entity assuming the role. In this case restrict it to the AWS SQS service. By requiring the AWS SQS as the consumer of our notifications we protect against notifications getting lost because the consuming application cannot match the rate of the notifications.

When an entity assumes a role the managed policies determine what resources they are allowed to access.

``` terraform
resource "aws_iam_policy" "racing_lambda_subscriber" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SNS:Subscribe",
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.further_processing.arn
        Condition = {
          StringEquals = {
            "sns:Protocol" = "https"
          }
        }
      },
    ]
  })
}
```

The policy for the racing_lambda_subscribe permits access to the `Subscribe` action to our topic provided that access is encrypted as we wish to ensure that the names and contact information are encrypted in transit.
