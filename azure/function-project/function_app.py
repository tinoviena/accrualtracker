import azure.functions as func
from azure.core.exceptions import ResourceExistsError
from azure.data.tables import TableServiceClient, TableClient
from azure.core.credentials import AzureNamedKeyCredential
import logging
import json
import hashlib
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

BuggerOffResponse = func.HttpResponse(
                    "Awesome!",
                    status_code=400
                )

@app.route(route="mk_acc_http_trigger")
def mk_acc_http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    credential = AzureNamedKeyCredential(os.environ["AZ_TABLE_ACCOUNT_NAME"], os.environ["AZURE_TABLE_ACCOUNT_KEY"])

    logging.info('Python HTTP trigger function processed a request.')

    response = {}
    try:
        req_body = json.loads(req.get_body())
        sec = req_body.get("secret")
        if (sec == None or sec == '' or sec != "c0fa0758-b954-11ee-9a88-3baa8ec87383"):
            return BuggerOffResponse
        
        with TableServiceClient(endpoint="https://ml015707162299.table.core.windows.net", credential=credential) as table_service_client:
            properties = table_service_client.get_service_properties()
            table_client = table_service_client.get_table_client(table_name="Accruals")
            recs = req_body.get("records")
            if (recs == None):
                logging.error("FAIL - there is no 'records' element on root level")
                return BuggerOffResponse
            for my_entity in recs :
                if (not isValid(my_entity)):
                    #return BuggerOffResponse
                    continue
                my_entity["PartitionKey"] = "Accruals"
                my_entity["RowKey"] = sha1_hash(my_entity)
                logging.info(req_body)
                try:
                    entity = table_client.create_entity(entity=my_entity)
                    logging.info(f"SUCCESS - {my_entity['RowKey']} stored: {entity}")
                    response["id"] = my_entity["RowKey"]
                    response["message"] = str(entity)
                except ResourceExistsError as e:
                    logging.error(f'Entity with id {my_entity["RowKey"]} already exists {type(e).__name__}: {e}')
                    logging.info(f"Due to a ResourceExistsError nothing was stored of this: {my_entity}")
                except Exception as e:
                    logging.error(f'Storing {my_entity["RowKey"]} resulted in an error of type {type(e).__name__}: {e}')
                    logging.info(f"Due to a {type(e).__name__} nothing was stored of this: {my_entity}")

    except ValueError:
        pass

    return func.HttpResponse(
            json.dumps(response),
            status_code=200
    )

@app.route(route="mk_acc_http_trigger_read")
def mk_acc_http_trigger_read(req: func.HttpRequest) -> func.HttpResponse:
    credential = AzureNamedKeyCredential(os.environ["AZ_TABLE_ACCOUNT_NAME"], os.environ["AZURE_TABLE_ACCOUNT_KEY"])

    logging.info('Python HTTP trigger read function processed a request.')

    if (req.method == 'POST'):
        response = {}
        try:
            req_body = json.loads(req.get_body())
            sec = req_body.get("secret")
            if (sec == None or sec == '' or sec != "c0fa0758-b954-11ee-9a88-3baa8ec87383"):
                return BuggerOffResponse
            acc = req_body.get("account")
            if (acc == None):
                logging.error("FAIL - there is no 'records' element on root level")
                return BuggerOffResponse

            with TableClient(table_name="Accruals", endpoint="https://ml015707162299.table.core.windows.net", credential=credential) as table_client:
                #table_client = table_service_client.get_table_client(table_name="Accruals")
                try:
                    parameters = {
                        "account": acc,
                    }
                    query_filter = "account eq @account"
                    records = table_client.query_entities(query_filter, parameters=parameters)
                    total = 0
                    total = sum(d['amountEuro'] for d in records) 

                    logging.info(f"SUCCESS - {records}")
                    response["total"] = total
                    response["message"] = "we are happy"
                except Exception as e:
                    logging.error(f'resulted in an error of type {type(e).__name__}: {e}')
                    logging.info(f"Due to a {type(e).__name__} nothing was retrieved from this: {acc}")

        except ValueError:
            pass
    elif(req.method == 'GET'):
        return BuggerOffResponse
    
    return func.HttpResponse(
            json.dumps(response),
            status_code=200
    )


def isValid(record):
    retVal = True
    msg = ""
    # should match:
    # {day: 2024-01-27T08:26:25.206882, description: Billa, moneyValueInEuros: 32.43, account: essen}
    if (record.get("day") == None):
        msg = f'day is {record.get("day")}'
        retVal = False
    if (record.get("description") == None):
        msg = f'description is {record.get("description")}'
        retVal = False
    if (record.get("amountEuro") == None):
        msg = f'amountEuro is {record.get("amountEuro")}'
        retVal = False
    if (record.get("account") == None):
        msg = f'account is {record.get("account")}'
        retVal = False

    if (retVal == False):
        print(logging.warn(f"This is not a valid record: {record} because {msg}"))
    return retVal

def sha1_hash(json_obj):
    """
    This function takes a JSON object/dictionary and returns its SHA-1 hash.
    """
    # Convert the JSON object/dictionary to a string
    json_str = json.dumps(json_obj, sort_keys=True)

    # Create a new SHA-1 hash object
    sha1 = hashlib.sha1()

    # Update the hash object with the JSON string
    sha1.update(json_str.encode())

    # Return the hexadecimal representation of the hash
    return sha1.hexdigest()