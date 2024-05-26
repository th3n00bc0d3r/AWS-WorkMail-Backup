# AWS WorkMail Backup and Import Automation
Automating the process of importing multiple AWS WorkMail mailboxes from S3 backups. Using a Python script, we initiate and manage import jobs for each mailbox, ensuring up to 10 concurrent jobs. The script tracks job statuses and organizes imports by user email, ensuring secure and efficient data restoration.

This repository provides scripts to automate the backup and import of AWS WorkMail mailboxes. It supports handling multiple users and can manage up to 10 concurrent jobs at a time.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Backup Mailboxes](#backup-mailboxes)
- [Import Mailboxes](#import-mailboxes)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following:

1. AWS CLI installed and configured.
2. Python 3.x installed.
3. Boto3 Python package installed (`pip install boto3`).

## Setup

### 1. Configure AWS CLI

Ensure the AWS CLI is configured with the necessary credentials:

```sh
aws configure
```

### 2. Set Up AWS Resources

Run the `setup_workmail_export.sh` script to create the required IAM roles, policies, S3 bucket, and KMS key.

Save the script as `setup_workmail_export.sh` and execute it:

```sh
chmod +x setup_workmail_export.sh
./setup_workmail_export.sh
```

This script will output the necessary variables required for the backup and import scripts.

### 3. Update Configuration Variables

Update the configuration variables in the Python scripts (`workmail_export.py` and `workmail_import.py`) with the values obtained from the setup script.

## Backup Mailboxes

### Description

The `workmail_export.py` script automates the process of exporting AWS WorkMail mailboxes and storing them in an S3 bucket, organized by user email and date.

### Usage

1. Update the `user_emails` dictionary in `workmail_export.py` with your AWS WorkMail user IDs and corresponding email addresses.
2. Run the script:

```sh
python workmail_export.py
```

This script will handle exporting mailboxes in batches of up to 10 concurrent jobs.

## Import Mailboxes

### Description

The `workmail_import.py` script automates the process of importing AWS WorkMail mailboxes from S3 backups back into AWS WorkMail, managing up to 10 concurrent import jobs.

### Usage

1. Update the `user_import_data` dictionary in `workmail_import.py` with your AWS WorkMail user IDs and corresponding email addresses.
2. Ensure the S3 objects containing the exported mailboxes exist and are accessible.
3. Run the script:

```sh
python workmail_import.py
```

This script will handle importing mailboxes in batches of up to 10 concurrent jobs.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Summary

- **Prerequisites**: Lists necessary installations and configurations.
- **Setup**: Details steps to configure AWS CLI, set up AWS resources, and update configuration variables.
- **Backup Mailboxes**: Instructions to use `workmail_export.py` for exporting mailboxes.
- **Import Mailboxes**: Instructions to use `workmail_import.py` for importing mailboxes.
- **License**: Includes the MIT license for the repository.