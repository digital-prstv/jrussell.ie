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
- queue the form data for recording on SQS
- return success when notification and acknowledgement are successful
- return an error if validation, notification or acknowledgement fail

If the acknowledgment or notification fails we want the visitor to retry. The loss of the record is not critical (as we will have the notification) and not a reason to force the visitor to enter their details again and get two (or more) acknowledgements.

## Supporting Cloud Infrastructure

We will use Terraform Infrastructure as Code to build the supporting services. I prefer Terraform over Cloud Foundation on the principle of selecting the more general tool. General tools provide better return on learning as they have wider applicability (unless you are happy to lock into a walled garden).

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

### S3

We need to create an S3 bucket to store the remote state for our infrastructure. We also want to control the configuration of this bucket using Terraform. Sounds like a bit of a chicken and egg conundrum.

Let's start by creating the bucket.

Create a Terraform file by convention the file is called main.tf but the name can be anything.

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

### Systems Manager

### Amazon Simple Email Service

### Simple Queue Service
