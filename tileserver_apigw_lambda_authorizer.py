'''
Lambda authorizer for tileserver http api gateway. Check performed:
- Validates the custom header value received from cloudfront against the
  value stored in AWS SSM parameter store
'''

import os
import logging
import boto3

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME = os.environ.get("TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME", None)
TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME = os.environ.get("TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME", None)

ssm = boto3.client("ssm", region_name=os.environ.get("AWS_REGION"))

def fetch_ssm_param(parameter_name):
    '''
    Get the parameter value from AWS SSM
    '''
    logger.info("Getting parameter value from SSM: %s", parameter_name)
    response = ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=True
    )
    return response["Parameter"]["Value"]

def is_authorized(event):
    '''
    Authorize the request based on the custom header value received from cloudfront
    '''
    # validating the custom authz token
    try:
        logger.info("Validating the custom authz token...")
        authz_token_value_from_ssm = fetch_ssm_param(TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME)
        authz_token_value_from_req_header = [v for k, v in event["headers"].items() if k.lower() == TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME.lower()][0]

        if authz_token_value_from_ssm != authz_token_value_from_req_header:
            logger.error("Custom authz token mismatch")
            return False

        logger.info("Custom authz token match")
    except Exception as ex:
        logger.error("Error validating the custom authz token. Reason: %s", ex)
        return False

    return True

def handler(event, context):
    '''
    Entry point for the lambda function
    '''
    return {
        "isAuthorized": is_authorized(event)
    }
