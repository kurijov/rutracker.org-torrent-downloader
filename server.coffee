config = require './config'
express = require('express')

app = express()

app.use(express.logger())
app.use(express.bodyParser())

app.use require('./mounts/add_torrent')
app.use require('./mounts/list')
app.use require('./mounts/check')

app.listen config.web_port
console.log 'listening at port:', config.web_port