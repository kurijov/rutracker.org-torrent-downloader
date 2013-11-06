Config  = require('../../db/config')

module.exports = (req, res, next) ->
  Config.get('transmission')
    .done (config) ->
      req.transmission = config
      next()