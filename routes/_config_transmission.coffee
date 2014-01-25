module.exports = (req, res, next) ->
  req.manager.transmission.getConfig().done (config) ->
    req.transmissionConfig = config
    next()