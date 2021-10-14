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
- retrieve the captcha service secret from the parameter store (Systems Manageer)
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

### S3

### Systems Manager

### Amazon Simple Email Service

### Simple Queue Service
