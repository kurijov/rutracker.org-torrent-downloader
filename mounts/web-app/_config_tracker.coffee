Config  = require('../../db/config')

module.exports = (req, res, next) ->
  Config.get('tracker')
    .done (config) ->
      req.tracker = config
      next()