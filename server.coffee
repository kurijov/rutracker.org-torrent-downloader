config        = require './config'
express       = require('express')

app = express()

app.use(express.logger())
app.use(express.bodyParser())
app.use(express.methodOverride())

app.use require('./mounts/web-app/main')

# app.use require('./mounts/add_torrent')
# app.use require('./mounts/remove_torrent')
# app.use require('./mounts/list')
# app.use require('./mounts/check')
# app.use require('./mounts/web-app')

app.listen config.web_port
console.log 'listening at port:', config.web_port