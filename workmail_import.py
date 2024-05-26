import boto3
import json
import time

# Configuration
organization_id = 'your-organization-id'
user_import_data = {
    'user-id-1': 'user1@example.com',
    'user-id-2': 'user2@example.com',
    'user-id-3': 'user3@example.com',
    'user-id-4': 'user4@example.com',
    'user-id-5': 'user5@example.com',
    'user-id-6': 'user6@example.com',
    'user-id-7': 'user7@example.com',
    'user-id-8': 'user8@example.com',
    'user-id-9': 'user9@example.com',
    'user-id-10': 'user10@example.com',
    'user-id-11': 'user11@example.com',
    'user-id-12': 'user12@example.com'
    # Add more user ID to email mappings as needed
}
s3_bucket_name = 's3.bucket.name'
s3_object_prefix = 'workmail-backup/'  # Prefix for S3 objects (folders)
region = 'your-region'
role_name = 'WorkMailImportRole'
account_id = 'your-account-id'

# Initialize AWS clients
workmail = boto3.client('workmail', region_name=region)
sts = boto3.client('sts', region_name=region)

def start_import_job(entity_id, user_email):
    client_token = str(time.time())  # Unique client token
    role_arn = f"arn:aws:iam::{account_id}:role/{role_name}"
    s3_object_key = f"{s3_object_prefix}{user_email}/export.zip"

    try:
        response = workmail.start_mailbox_import_job(
            ClientToken=client_token,
            OrganizationId=organization_id,
            EntityId=entity_id,
            Description='Import job',
            RoleArn=role_arn,
            S3BucketName=s3_bucket_name,
            S3ObjectKey=s3_object_key
        )
        return response['JobId']
    except Exception as e:
        print(f"Failed to start import job for {entity_id}: {e}")
        return None

def check_job_status(job_id):
    while True:
        try:
            response = workmail.describe_mailbox_import_job(
                OrganizationId=organization_id,
                JobId=job_id
            )
            state = response.get('State', 'UNKNOWN')
            print(f"Job State: {state}")

            if state in ['COMPLETED', 'FAILED']:
                break

        except Exception as e:
            print(f"Error checking job status for {job_id}: {e}")

        time.sleep(30)  # Wait for 30 seconds before checking again

    return state

def import_mailboxes_in_batches(user_import_data, batch_size=10):
    user_ids = list(user_import_data.keys())
    for i in range(0, len(user_ids), batch_size):
        batch = user_ids[i:i+batch_size]
        job_ids = []
        for user_id in batch:
            user_email = user_import_data[user_id]
            job_id = start_import_job(user_id, user_email)
            if job_id:
                print(f"Started import job for {user_email} with Job ID: {job_id}")
                job_ids.append((user_email, job_id))

        for user_email, job_id in job_ids:
            state = check_job_status(job_id)
            if state == 'COMPLETED':
                print(f"Import job for {user_email} completed successfully")
            else:
                print(f"Import job for {user_email} failed with state: {state}")

def main():
    import_mailboxes_in_batches(user_import_data)

if __name__ == "__main__":
    main()
