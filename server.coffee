config        = require './config'
express       = require('express')

app = express()

app.use(express.logger())
app.use(express.bodyParser())
app.use(express.methodOverride())

app.use require('./routes/main')

app.listen config.web_port
console.log "Listening at: http://localhost:#{config.web_port}"