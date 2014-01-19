app    = require './main'

app.all '/tracker', require('./_config_tracker')

app.get '/tracker', (req, res) ->

  res.render 'tracker.html', {page: 'tracker', tracker: req.tracker}

app.post '/tracker', (req, res) ->
  req.tracker.login    = req.param('login')
  req.tracker.password = req.param('password')
  req.tracker.$save().done ->
    res.redirect('/')

module.exports = app