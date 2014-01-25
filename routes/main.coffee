express = require('express')
swig    = require('swig')

swig.setDefaults({ 
  cache: (process.env.NODE_ENV is 'production') 
  varControls: ['[[', ']]']
});

connectAssets = require 'connect-assets'

app = express()

app.engine 'html', swig.renderFile
app.set 'view engine', 'html'
app.set 'views', __dirname + '/../views'
app.set 'view cache', (process.env.NODE_ENV is 'production')

app.use connectAssets({
  src: __dirname + '/../public'
})

app.use(express.static(__dirname + '/public'))

app.all '*', (req, res, next) ->
  res.respond = (qPromise) ->
    qPromise
    .fail (error) ->
      res.status 500
      error
    .done (result) -> 
      console.log 'responding with', result
      res.json result

  next()

app.all '*', (req, res, next) ->
  req.manager = require('../manager')
  next()

app.get '/', (req, res) ->
  res.render 'index.html', {page: 'torrents'}

module.exports = app

require './torrents'
require './transmission'