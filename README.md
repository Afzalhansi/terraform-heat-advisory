# Terraform Heat Advisory — S3 Static Website

My first Terraform project — provisioning a public static website on AWS S3 entirely
through Infrastructure as Code, no manual console clicking.

## What it does

Deploys a single-page **UAE Heat Safety Advisory** site, hosted on an S3 bucket
configured for static website hosting.

Live URL: `http://uae-heat-advisory-afzal.s3-website.eu-north-1.amazonaws.com/)`

## Architecture

```
                 ┌─────────────────────────────┐
                 │   aws_s3_bucket              │
                 │   uae-heat-advisory-afzal    │
                 └───────────────┬─────────────┘
                                 │
      ┌──────────────────────────┼──────────────────────────┐
      │                          │                          │
┌─────▼──────────┐   ┌───────────▼────────────┐   ┌─────────▼─────────┐
│ website_        │   │ public_access_block    │   │ bucket_policy      │
│ configuration   │   │ (unblocks public       │   │ (grants public     │
│ (index.html as  │   │ access for hosting)    │   │ s3:GetObject)      │
│ homepage)       │   │                        │   │                    │
└─────────────────┘   └────────────────────────┘   └─────────┬──────────┘
                                                               │
                                                    ┌──────────▼──────────┐
                                                    │  aws_s3_object       │
                                                    │  index.html          │
                                                    │  (uploaded via TF)   │
                                                    └───────────────────────┘
```

- **`aws_s3_bucket`** — the base bucket
- **`aws_s3_bucket_website_configuration`** — turns the bucket into a static website host, sets `index.html` as the entry point
- **`aws_s3_bucket_public_access_block`** — disables AWS's default public-access block (required for a public site)
- **`aws_s3_bucket_policy`** — explicit IAM policy granting `s3:GetObject` to everyone, so visitors can actually load the page
- **`aws_s3_object`** — uploads `index.html` into the bucket; Terraform tracks its content hash (`filemd5`) and only re-uploads when the file changes

## Prerequisites

- Terraform >= 1.16
- AWS CLI configured with credentials that have S3 permissions (`aws configure`)

## Usage

```bash
terraform init      # download the AWS provider
terraform plan       # preview what will be created
terraform apply      # create the resources (type 'yes' to confirm)
```

Terraform will print the live website URL as an output once `apply` finishes.

To tear everything down:

```bash
terraform destroy
```

## What I learned

- Core Terraform workflow: `init → plan → apply`, and reading a plan diff (`+`/`~`/`-`) before ever confirming
- How Terraform state lets it detect exactly what changed (e.g. only re-uploading `index.html` when its content hash changed, without touching the bucket or policy)
- S3 static website hosting requires three separate pieces working together: website config, public access block, and bucket policy — not just one setting
- `depends_on` to control resource creation order when Terraform can't infer it automatically

## Notes

- Region: `eu-north-1`
- This is a learning project — the S3 bucket public-read policy is intentional here since the site is meant to be public, but wouldn't be appropriate for anything containing non-public data.
