fetch('https://mh44unhmlk.execute-api.us-east-1.amazonaws.com/counterapi/')
.then(response => response.json())
.then((data) => {
    document.getElementById('pagecounter').innerText = data.count
})