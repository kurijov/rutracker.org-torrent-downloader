app    = require './main'

app.get '/tracker', (req, res) ->
  req.manager.tracker.getConfig().done (trackerConfig) ->
    res.render 'tracker.html', {page: 'tracker', tracker: trackerConfig}

app.post '/tracker', (req, res) ->
  req.manager.tracker.getConfig()
    .then (trackerConfig) ->
      trackerConfig.login    = req.param 'login'
      trackerConfig.password = req.param 'password' 

      trackerConfig.$save()
        .then ->
          req.manager.tracker.authorize()
        .done ->
          res.redirect '/'
        , (error) ->
          res.render 'tracker.html', {page: 'tracker', tracker: trackerConfig, error}
