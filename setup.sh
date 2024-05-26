#!/bin/bash

# Configuration
ROLE_NAME="WorkMailExportRole"
POLICY_NAME="workmail-export"
S3_BUCKET_NAME="s3.bucket.name"
AWS_REGION="your-region"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create Trust Policy
cat <<EOF > trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "export.workmail.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "$ACCOUNT_ID"
                }
            }
        }
    ]
}
EOF

# Create IAM Role
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust-policy.json

# Create IAM Policy
cat <<EOF > role-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::$S3_BUCKET_NAME",
                "arn:aws:s3:::$S3_BUCKET_NAME/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Attach the Policy to the Role
aws iam put-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME --policy-document file://role-policy.json

# Create S3 Bucket
aws s3api create-bucket --bucket $S3_BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION

# Create Key Policy
cat <<EOF > key-policy.json
{
    "Version": "2012-10-17",
    "Id": "workmail-export-key",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$ACCOUNT_ID:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow administration of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Create the KMS Key and get the Key ID and ARN using Python for JSON parsing
KEY_METADATA=$(aws kms create-key --policy file://key-policy.json)
KEY_ID=$(python3 -c "import sys, json; print(json.load(sys.stdin)['KeyMetadata']['KeyId'])" <<< "$KEY_METADATA")
KEY_ARN=$(python3 -c "import sys, json; print(json.load(sys.stdin)['KeyMetadata']['Arn'])" <<< "$KEY_METADATA")

# Update S3 Bucket Policy
cat <<EOF > s3_bucket_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
            },
            "Action": "s3:*"
            "Resource": [
                "arn:aws:s3:::$S3_BUCKET_NAME",
                "arn:aws:s3:::$S3_BUCKET_NAME/*"
            ]
        }
    ]
}
EOF

# Apply the Bucket Policy
aws s3api put-bucket-policy --bucket $S3_BUCKET_NAME --policy file://s3_bucket_policy.json

# Clean up temporary files
rm trust-policy.json role-policy.json key-policy.json s3_bucket_policy.json

# Display the variables required for the backup script
cat <<EOF

Setup complete. Here are the variables required for the backup script:

# Print out the Variables
organization_id = 'your-organization-id'
user_id = 'your-user-id'
s3_bucket_name = '$S3_BUCKET_NAME'
s3_prefix = 'workmail-backup/'
region = '$AWS_REGION'
kms_key_arn = '$KEY_ARN'
role_name = '$ROLE_NAME'
account_id = '$ACCOUNT_ID'

EOF