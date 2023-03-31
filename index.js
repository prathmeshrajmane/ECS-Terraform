const express = require('express')
const app = express()
const port = 5006

app.get('/', (req, res) => res.send('Welcome This Page is running on ECR Farget:v4'))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
