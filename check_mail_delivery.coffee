nodemailer = require("nodemailer")
config     = require './config'

transport = nodemailer.createTransport("SMTP", config.smtp_options)

mailOptions =
  from: config.deliver_mail.from
  to: config.deliver_mail.to
  subject: "Just the test if email works"
  text: "mail works!"
  html: "mail works!"

console.log "sending mail from:", config.deliver_mail.from
console.log "sending mail to:", config.deliver_mail.to

transport.sendMail mailOptions, (error, response) ->
  console.log error, response

  transport.close()