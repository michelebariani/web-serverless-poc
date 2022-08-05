import os
import boto3

dynamo = boto3.resource('dynamodb')
dynamo_table_name = os.environ['dynamodb_table_name']

html_template = """<html>
<head><title>Welcome</title></head>
<body>
<p>%s</p>
</body>
</html>
"""

def handler(event, context):
    if event['httpMethod'] != 'GET':
        return { 'statusCode': 400 }

    try:
        message = dynamo.Table(dynamo_table_name).get_item(Key={ 'message': 'welcome' })['Item']['value']
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'text/html'},
            'body': html_template % message
        }
    except:
        return { 'statusCode': 404 }
