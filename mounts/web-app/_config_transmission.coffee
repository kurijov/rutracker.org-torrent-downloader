Config       = require('../../db/config')
transmission = new (require('../../downloaders/transmission'))

module.exports = (req, res, next) ->
  req.transmission = transmission

  Config.get('transmission')
    .done (config) ->
      req.transmissionConfig = config
      next()