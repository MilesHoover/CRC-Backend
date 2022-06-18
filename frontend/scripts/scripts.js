fetch ("https://mh44unhmlk.execute-api.us-east-1.amazonaws.com/counterapi/apiresource")
.then(res => res.json())
.then(data => document.getElementById('pagecount').innerText=data)