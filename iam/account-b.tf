provider "aws" {
  alias  = "account_b"
  region = "eu-central-1"
}

locals {
  target_bucket_name = "account-b-shared-bucket"
}

resource "aws_s3_bucket" "shared" {
  provider = aws.account_b
  bucket   = local.target_bucket_name
}

data "aws_iam_policy_document" "roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::000000000000:role/roleB"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["roleB-to-roleC-2026"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  provider           = aws.account_b
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

data "aws_iam_policy_document" "roleC_s3_access" {
  statement {
    sid    = "FullAccessToNamedBucket"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.shared.arn,
      "${aws_s3_bucket.shared.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "roleC_policy" {
  provider = aws.account_b
  name     = "roleC-s3-full-access-single-bucket"
  role     = aws_iam_role.roleC.id
  policy   = data.aws_iam_policy_document.roleC_s3_access.json
}
