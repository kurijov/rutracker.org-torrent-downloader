app    = require './main'

app.all '/transmission*', require('./_config_transmission')

app.get '/transmission/:error?', (req, res) ->
  data = 
    host: req.transmission.host
    download_dir: req.transmission.download_dir
    page: 'transmission'
    error: req.param('error')

  res.render 'transmission.html', data

app.post '/transmission', (req, res) ->
  req.transmission.host = req.param('host')
  req.transmission.download_dir = req.param('download_dir')
  req.transmission.$save().done ->
    res.redirect '/'


module.exports = app