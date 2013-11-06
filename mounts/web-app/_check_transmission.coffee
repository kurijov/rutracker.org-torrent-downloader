module.exports = (req, res, next) ->
  unless req.transmission.host
    res.redirect('/transmission/no_host')
  else
    require('../../actions/get_session')().then ->
      next()
    , (error) ->
      res.redirect('/transmission/no_connection')
