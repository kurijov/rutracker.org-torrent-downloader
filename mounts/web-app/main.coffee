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
app.set 'views', __dirname + '/views'
app.set 'view cache', (process.env.NODE_ENV is 'production')

app.use connectAssets({
  src: __dirname + '/public'
})

app.use(express.static(__dirname + '/public'))

app.get '/', require('./_config_transmission'), require('./_check_transmission')
app.get '/', (req, res) ->
  res.render 'index.html', {page: 'torrents'}

module.exports = app