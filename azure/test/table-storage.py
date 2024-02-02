import sys

account_name = 'devstoreaccount1'
access_key = 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=='
endpoint = 'http://127.0.0.1:10002/devstoreaccount1'

def absk():
    authentication_by_shared_key() 
def authentication_by_shared_key():
        print("Instantiate a TableServiceClient using a shared access key")
        # [START auth_from_shared_key]
        from azure.data.tables import TableServiceClient
        from azure.core.credentials import AzureNamedKeyCredential

        credential = AzureNamedKeyCredential(account_name, access_key)
        with TableServiceClient(endpoint=endpoint, credential=credential) as table_service_client:
            properties = table_service_client.get_service_properties()
            print(f"{properties}")

if (__name__ == '__main__'):
    arg = sys.argv[1]
    if (arg == 'write'):
        test_write()
    elif (arg == 'read'):
        test_read()
    else:
        method_name = sys.argv[1]
        try:
            method = getattr(sys.modules[__name__], method_name)
        except AttributeError:
            print(f"Error: {method_name} is not a valid method name.")
            sys.exit(1)
        method()      