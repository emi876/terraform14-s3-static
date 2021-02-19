# Using this Terraform Code

## Instructions for Use

This terraform code can be used to create the resources required to host a static website on s3 in an automated manner. Several resources are created including:
> 1. 2 CloudFront Distributions
> 2. Route 53 hosting zone
> 3. 2 S3 Buckets
> 4. An Amazon Certicate Manager SSL Certificate

### Using Terraform

> * [AWS CLI Version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
> * [Terraform 0.14](https://www.terraform.io/downloads.html)
> * Properly configured AWS Credentials with programmatic access the appropriate permissions
> * A domain name
> * An S3 bucket created on the console to store your state file remotely (if you are collaborating with other team mates)
> * A DynamoDB table for state lock (not created in this repo)

Before using this code, register a domain name (I recommend [Namecheap](https://namecheap.com) which also allows you to create an <user@yourdomain.com>
email address and forward to an existing mailbox you have access to without creating an email server for your newly registered domain.
The reason to do this is because there are two validation methods of DNS ownership using Amazon Certificate Mangager certificate.
Validation can be done via Email or via DNS Verification. Email validation is generally easier and so that's what I use. Terraform only sends validation
emails to certain email address within your domain . Full list can be accessed here [terraform email validation](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest/examples/complete-email-validation)

Create an s3 bucket on the console to store the state file, name it whatever you want but make a note of it as you will need the name when modifying your backend.tf resource. Attach the following
policy to the bucket you created on the console (ensure it is created in the same region you want to create all your terraform resources escept the CloudFront distribtuion which always has to be
created in us-east-1):

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::ACCOUNT_NUMBER:root"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::bucket-name"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::ACCOUNT_NUMBER:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::bucket-name/*"
        }
    ]
}
```
Ensure you replace ***ACCOUNT_NUMBER*** with your own AWS account number and ***bucket-name*** with the name of your bucket.

Next you want to modify the name of your bucket in the ***backend.tf*** file 
You also want to make the neccessary changes in the ***terraform.tfvars*** file at this time otherwise you will be prompted to input them after
you run terraform apply.


After registering a domain name, setting up email forwarding and creating a S3 bucket with the policy in is run the following commands:

> 1. To initialize terraform and install all the required plugins:

```bash
terraform init
```

> 2. To validate your code (optional) and ensure everything is ok run:

```bash
terraform validate
```
> 3. To see the resources that will be created run:

```bash
terraform plan
```

> 4. To apply the changes run the following command:

```bash
terraform apply-auto-approve
```

After running the fourth command you will receive an email form AWS asking you toi validate your ACM SSL certificate. Go ahead and approve this. Once that's done all the rest of the resources will be created automatically.

### Migrating Your Content
> 1. Prior to migrating your content, you would to ensure your domain nameservers in Namecheap point to the AWS nameservers which can be found in the NS record of your Terraform created hosted zone in the AWS console.

> 2. Once that is done, cd into the directory which contains the code you want to upload and run this command to migrate all the content to your S3 bucket:

```bash
aws s3 sync . s3://www.yourdomain.com
```
> 3. Finally, run this command (you have to modify the ***CLOUDFRONT-ID*** associated with your www bucket prior to running this code) :

```bash
aws cloudfront create-invalidation --distribution-id CLOUDFRONT-ID --paths "/*";
```

THAT'S ALL FOLKS! WE HAVE SUCCESSFULLY CREATED THE INFRASTRUCTURE AND MIGRATED OUR CONTENT TO AWS TO SERVE LIGHTENING SPEEED CONTENT ACROSS THE GLOBE SECURELY USING CLOUDFRONT AND S3.

