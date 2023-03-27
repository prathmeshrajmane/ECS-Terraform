const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => res.send('Welcome This Page is running on ECR Farget:v1'))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
