app    = require './main'

app.all '/transmission*', require('./_config_transmission')

app.get '/transmission/:error?', (req, res) ->
  data = 
    host: req.transmissionConfig.host
    download_dir: req.transmissionConfig.download_dir
    page: 'transmission'
    error: req.param('error')

  res.render 'transmission.html', data

app.post '/transmission', (req, res) ->
  req.transmissionConfig.host = req.param('host')
  req.transmissionConfig.download_dir = req.param('download_dir')
  req.transmissionConfig.$save().done ->
    res.redirect '/'


module.exports = app