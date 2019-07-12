resource "aws_iam_group" "gadgetry" {
  name = "Gadgetry"
  path = "/consultants/"
}

resource "aws_iam_group_policy_attachment" "attached_policies" {
  count      = "${length(var.attached_policies)}"
  group      = "${aws_iam_group.gadgetry.name}"
  policy_arn = "${element(var.attached_policies, count.index)}"
}

resource "aws_iam_group_policy" "inline_policy" {
  name   = "gadgetry"
  group  = "${aws_iam_group.gadgetry.id}"
  policy = "${data.aws_iam_policy_document.inline_policy.json}"
}

variable "attached_policies" {
  default = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::aws:policy/IAMSelfManageServiceSpecificCredentials",
  ]
}

data "aws_iam_policy_document" "inline_policy" {
  # Allow Session Manager access in "QA" environment.
  # Update the resource tag or environments as necessary
  statement {
    sid       = "SessionManager"
    actions   = ["ssm:StartSession"]
    resources = ["*"]

    condition = {
      test     = "StringLike"
      variable = "ssm:resourceTag/Environment"
      values   = ["qa"]
    }
  }

  # Allow Gadgetry to terminate their own Sessions
  statement {
    sid       = "SessionManagerTermination"
    actions   = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:*:session/$${aws:username}-*"]
  }
}
