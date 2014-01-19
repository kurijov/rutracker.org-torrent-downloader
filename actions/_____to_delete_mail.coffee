nodemailer = require("nodemailer")
config     = require '../config'


smtp_options = config.smtp_options

module.exports = (dbInstance) ->
  return if Object.keys(smtp_options).length is 0

  transport = nodemailer.createTransport("SMTP", smtp_options)

  mailOptions =
    from: config.deliver_mail.from
    to: config.deliver_mail.to
    subject: "we have reloaded torrent"
    text: "#{dbInstance.tracker_title} scheduled"
    html: "<b>#{dbInstance.tracker_title}</b> scheduled"

  transport.sendMail mailOptions, (error, response) ->
    console.log error, response

    transport.close()