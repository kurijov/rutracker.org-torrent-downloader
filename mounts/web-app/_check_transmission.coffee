module.exports = (req, res, next) ->
  unless req.transmissionConfig.host
    res.redirect('/transmission/no_host')
  else
    # require('../../actions/get_session')().then ->
    req.transmission.get_session().then ->
      next()
    , (error) ->
      res.redirect('/transmission/no_connection')
