### Quick and Dirty Setup
```
open setup.sh

//Update
ROLE_NAME="WorkMailExportRole"
POLICY_NAME="workmail-export"
S3_BUCKET_NAME="s3.bucket.name"
AWS_REGION="your-region"

//Run Setup
chmod +x setup.sh
./setup.sh

//Install
pip install boto3
python workmail_import.py
python workmail_export.py
```