express       = require('express')
swig = require('swig')

swig.setDefaults({ 
  cache: (process.env.NODE_ENV is 'production') 
  varControls: ['[[', ']]']
});

connectAssets = require 'connect-assets'

app = express()

app.engine 'html', swig.renderFile
app.set 'view engine', 'html'
app.set 'views', __dirname + '/views'
app.set 'view cache', (process.env.NODE_ENV is 'production')

app.use connectAssets({
  src: __dirname + '/public'
})

app.get '/', (req, res) ->
  res.render 'index.html'

require('../../db/config').get('torrent/rutracker.org').then (config) ->
  console.log 'ok', config
  console.log 'ok', config.user
  console.log 'ok', config.password

  # config.user = "hello"
  # config.password = "there"
  # config.$save().then ->
  #   console.log 'done'
.done()

module.exports = app