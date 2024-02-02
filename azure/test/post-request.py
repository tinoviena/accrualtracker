import sys
import requests
import json

base_url = 'http://localhost:7071/api'
base_url = 'https://mk-acc-http-trigger.azurewebsites.net/api'
def test_write_one(args):
    (amount, desc, account) = args
    url = base_url + '/mk_acc_http_trigger'
    data = {    
        "secret": "c0fa0758-b954-11ee-9a88-3baa8ec87383",
        "name": "Sweet Jane",
        "records": [
            {
                "day": "2022-01-28",
                "amountEuro": float(amount),
                "description": desc,
                "account": account,
            },
        ]
    }

    result = make_call(url, data)
    print(result)

def test_write():
    url = base_url + '/mk_acc_http_trigger'
    data = {    
        "secret": "c0fa0758-b954-11ee-9a88-3baa8ec87383",
        "name": "Sweet Jane",
        "records": [
            {
                "day": "2022-01-28",
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
    result = make_call(url, data)
    print(result)


def test_read():
    url = base_url + '/mk_acc_http_trigger_read'
    data = {
        "secret": "c0fa0758-b954-11ee-9a88-3baa8ec87383", 
        'account': 'essen',
    }
    result = make_call(url, data)
    print(result)

def make_call(url, data):
    headers = {'x-functions-key': sys.environ('AZURE_X_FUNCTIONS_KEY')}
    response = requests.post(url, headers=headers, json=data)

    return f"{response.status_code}: {response.text}: {response.content}"

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
        if (len(sys.argv[2:])>0):
            method(sys.argv[2:])
        else:
            method()

