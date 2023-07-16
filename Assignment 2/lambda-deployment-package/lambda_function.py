import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus
from PIL import Image
from botocore.exceptions import ClientError

"""
To build an AWS Lambda deployment package, see:
https://stackoverflow.com/a/61944380/2599401
https://docs.aws.amazon.com/lambda/latest/dg/with-s3-tutorial.html#with-s3-tutorial-create-function-package

This Lambda function accepts the following input:    {"bucketName":"your-photo-bucket-name","fileName":"your-photo.png"}
ONLY PNG FILES ARE SUPPORTED!!
This Lambda function downloads your-photo.png from your-photo-bucket-name S3 bucket, resizes the pic, then upload the resized pic (resized-your-photo.png) to the same bucket
"""

s3_client = boto3.client('s3')

def resize_image(image_path, resized_path):
    with Image.open(image_path) as image:
        image.thumbnail(tuple(x / 2 for x in image.size))
        image.save(resized_path)

def lambda_handler(event, context):
    try:
        bucket_name = event["bucketName"]
        file_name = event["fileName"]
        key = unquote_plus(file_name)
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        s3_client.download_file(bucket_name, key, download_path)
        resize_image(download_path, upload_path)
        s3_client.upload_file(upload_path, bucket_name, 'resized-{}'.format(tmpkey))
    except ClientError as e:
        return "Lambda's error: Error code: {}, HTTPStatusCode: {}, Message: {}".format(e.response['Error']['Code'], e.response['ResponseMetadata']['HTTPStatusCode'], e.response['Error']['Message'])
    except OSError as ose:
        return "Lambda's error: Message: {}".format(ose)