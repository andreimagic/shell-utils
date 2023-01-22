from urllib.request import urlopen
import json

url = "http://localhost:8081"

response = urlopen(url)  
data_json = json.loads(response.read())
status = data_json['alpha']['status']
# print(status)

if status == "healthy":
    exit(0)
else:
    exit(1)