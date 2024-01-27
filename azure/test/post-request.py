import requests
import json

url = 'http://localhost:7071/api/mk_acc_http_trigger'
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

response = requests.post(url, json=json.dumps(data))
print(response.status_code)
print(response.text)