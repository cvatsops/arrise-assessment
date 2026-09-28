provider "aws" {
  alias  = "account_a"
  region = "eu-central-1"
}

resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1-programmatic-only"
}

resource "aws_iam_user" "engine" {
  provider = aws.account_a
  name     = "engine"
}

resource "aws_iam_user" "ci" {
  provider = aws.account_a
  name     = "ci"
}

resource "aws_iam_user_group_membership" "group1_members" {
  provider = aws.account_a
  user     = aws_iam_user.engine.name
  groups   = [aws_iam_group.group1.name]
}

resource "aws_iam_user_group_membership" "group1_members_ci" {
  provider = aws.account_a
  user     = aws_iam_user.ci.name
  groups   = [aws_iam_group.group1.name]
}

data "aws_iam_policy_document" "group1_deny_console" {
  statement {
    sid       = "DenyConsolePasswordManagement"
    effect    = "Deny"
    actions   = ["iam:CreateLoginProfile", "iam:UpdateLoginProfile"]
    resources = ["*"]
  }
}

resource "aws_iam_group_policy" "group1_guardrail" {
  provider = aws.account_a
  name     = "deny-console-login-profile"
  group    = aws_iam_group.group1.name
  policy   = data.aws_iam_policy_document.group1_deny_console.json
}

resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2-console-and-cli"
}

resource "aws_iam_group_policy_attachment" "group2_power_user" {
  provider   = aws.account_a
  group      = aws_iam_group.group2.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_user" "alice" {
  provider = aws.account_a
  name     = "alice"
}

resource "aws_iam_user" "bob" {
  provider = aws.account_a
  name     = "bob"
}

resource "aws_iam_user_group_membership" "group2_members_alice" {
  provider = aws.account_a
  user     = aws_iam_user.alice.name
  groups   = [aws_iam_group.group2.name]
}

resource "aws_iam_user_group_membership" "group2_members_bob" {
  provider = aws.account_a
  user     = aws_iam_user.bob.name
  groups   = [aws_iam_group.group2.name]
}


data "aws_iam_policy_document" "roleA_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::000000000000:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["o-exampleorgid"]  
    }
  }
}

resource "aws_iam_role" "roleA" {
  provider           = aws.account_a
  name               = "roleA"
  assume_role_policy = data.aws_iam_policy_document.roleA_trust.json
}

data "aws_iam_policy_document" "roleA_admin_except_iam" {
  statement {
    sid       = "AllowEverything"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyIAM"
    effect = "Deny"
    actions = [
      "iam:*",
      "organizations:*",   
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "roleA_policy" {
  provider = aws.account_a
  name     = "admin-except-iam"
  role     = aws_iam_role.roleA.id
  policy   = data.aws_iam_policy_document.roleA_admin_except_iam.json
}


data "aws_iam_policy_document" "roleB_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::000000000000:root"]
    }
  }
}

resource "aws_iam_role" "roleB" {
  provider           = aws.account_a
  name               = "roleB"
  assume_role_policy = data.aws_iam_policy_document.roleB_trust.json
}

data "aws_iam_policy_document" "roleB_permissions" {
  statement {
    sid       = "AssumeRoleCInAccountB"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::111111111111:role/roleC"]
  }
}

resource "aws_iam_role_policy" "roleB_policy" {
  provider = aws.account_a
  name     = "assume-roleC-only"
  role     = aws_iam_role.roleB.id
  policy   = data.aws_iam_policy_document.roleB_permissions.json
}
