config = require '../config'
async  = require 'async'
fs     = require 'fs'

Browser = require("zombie")

browser = new Browser debug: no
cookieFilePath = __dirname + "/../.cookies"

savedCookies = no

getCookies = (callback) ->
  return callback null, savedCookies if savedCookies

  async.waterfall [
    (callback) -> # check cookies
      try
        cookies = JSON.parse fs.readFileSync(cookieFilePath)
      catch error
        cookies = null

      if cookies
        console.log 'using cookies from file', cookies
        return callback null, cookies
      else
        async.waterfall [
          (callback) -> browser.visit "http://rutracker.org/forum/index.php", callback
          (callback) ->
            browser.fill("login_username", config.user.login)
            browser.fill("login_password", config.user.password)
            browser.pressButton("login", callback)
          (callback) -> browser.wait callback
          (callback) ->
            callback null, browser.cookies.serialize("rutracker.org").split(';')
          (cookies, callback) ->
            str = JSON.stringify(cookies)
            fs.writeFileSync cookieFilePath, str
            callback null, cookies
        ], callback

  ], (error, cookies) ->
    savedCookies = cookies
    callback error, cookies


module.exports = (removeCookies, callback) ->
  if 'function' is typeof removeCookies
    callback = removeCookies
    removeCookies = no

  if removeCookies
    savedCookies = no
    fs.unlinkSync cookieFilePath

  getCookies callback

