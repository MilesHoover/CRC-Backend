fetch ('https://ak2nkurklj.execute-api.us-east-1.amazonaws.com/prod/count')
.then(res => res.json())
.then(data => document.getElementById('pagecount').innerText=data)