import boto3

client = boto3.client('ec2')

response = client.describe_images(
    Filters=[
        {
            'Name': 'platform',
            'Values': [
                'windows',
            ]
        },
        {
            'Name': 'name',
            'Values': [
                'Windows_Server-2019-English-Full-SQL_2019_Web*'
            ]
        }
    ],
    Owners=[
        'amazon',
    ],
    IncludeDeprecated=True
)
sorted_list = sorted(response['Images'], key=lambda k: k['Name'])

for image in sorted_list:
    print(f"{image['Name']}: {image['CreationDate']}")

