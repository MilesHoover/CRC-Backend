fetch('PUT')
.then(() => fetch('GET'))
.then(response => response.json())
.then((data) => {
    document.getElementById('pagecount').innerText = data.count
})