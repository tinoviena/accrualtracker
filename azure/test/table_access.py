from os import environ
from azure.data.tables import TableServiceClient
from azure.core.credentials import AzureNamedKeyCredential
from datetime import datetime

PRODUCT_ID = u'001234'
PRODUCT_NAME = u'RedMarker'
AZ_TABLE_ACCOUNT_NAME = environ('AZ_TABLE_ACCOUNT_NAME')
AZURE_TABLE_ACCOUNT_KEY = environ('AZURE_TABLE_ACCOUNT_KEY')

my_entity = {
    u'PartitionKey': PRODUCT_NAME,
    u'RowKey': PRODUCT_ID,
    u'Stock': 15,
    u'Price': 9.99,
    u'Comments': u"great product",
    u'OnSale': True,
    u'ReducedPrice': 7.99,
    u'PurchaseDate': datetime(1973, 10, 4),
    u'BinaryRepresentation': b'product_name'
}

credential = AzureNamedKeyCredential(AZ_TABLE_ACCOUNT_NAME, AZURE_TABLE_ACCOUNT_KEY)
table_service_client = TableServiceClient(endpoint=f"https://{AZ_TABLE_ACCOUNT_NAME}.table.core.windows.net", credential=credential)
#table_service_client = TableServiceClient.from_connection_string(conn_str="<connection_string>")
table_client = table_service_client.get_table_client(table_name="Accruals")

entity = table_client.create_entity(entity=my_entity)