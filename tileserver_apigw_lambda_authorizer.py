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

def fetch_ssm_param(parameter_name: str) -> str:
    '''
    Get the parameter value from AWS SSM

    Args:
        parameter_name: Name of the SSM parameter to fetch

    Returns:
        str: Value of the SSM parameter
    '''
    logger.info("Getting parameter value from SSM: %s", parameter_name)
    response = ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=True
    )
    return response["Parameter"]["Value"]

def is_authorized(event: dict) -> bool:
    '''
    Authorize the request based on the custom header value received from cloudfront

    Args:
        event: Event received from the API Gateway

    Returns:
        bool: True if the request is authorized, False otherwise
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

def handler(event: dict, context: dict) -> dict:
    '''
    Entry point for the lambda function

    Args:
        event: Event received from the API Gateway
        context: Context received from the API Gateway

    Returns:
        dict: Response from the lambda function
    '''

    if (TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME is None
        or TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME is None
    ):
        logger.error("TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME or \
                      TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME is not set")
        return {
            "isAuthorized": False
        }

    return {
        "isAuthorized": is_authorized(event)
    }
