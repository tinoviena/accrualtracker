import sys
import requests
import json

base_url = 'http://localhost:7071/api'

def test_write():
    url = base_url + '/mk_acc_http_trigger'
    data = {    
        "secret": "c0fa0758-b954-11ee-9a88-3baa8ec87383",
        "name": "Sweet Jane",
        "records": [
            {
                "day": "2022-01-01",
                "amountEuro": 100.2,
                "description": "Groceries",
                "account": "essen",
            },
            {
                "day": "2022-01-02",
                "amountEuro": 50.0,
                "description": "Gasoline",
                "CUNT": "",
            }
        ]
    }

    response = requests.post(url, json=data)
    print(response.status_code)
    print(response.text)

def test_read():
    url = base_url + '/mk_acc_http_trigger_read'
    data = {
        "secret": "c0fa0758-b954-11ee-9a88-3baa8ec87383", 
        'account': 'essen',
    }
    response = requests.post(url, json=data)
    print(response.status_code)
    print(response.text)

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
