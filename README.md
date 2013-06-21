rutracker.org
======

the app allows to watch favourite series by checking themes at rutracker.org


Requirements
-------

`nodejs` - tested on 0.10.2
`transmission`

Installation
-------
just run `npm install`

Configuration
-------

1. Rename `config.example` to `config.coffee`
2. Options description:
  These ones you will want to set
  `user.login` - your rutracker login
  `user.password` - your rutracker password
  `check_period` - time in seconds, period to check for changes

  if you wish to get email when torrent started new downlaod, you can set these params

  `smtp_options` - check available options at https://github.com/andris9/Nodemailer
  `deliver_mail.to` - address to deliver
  `deliver_mail.from` - used in `from` field


  These ones you wont want to change
  `transmission.host` - transmission rpc url
  
  `web_port` - application creates web server in order to expose some api, this port will be used for listening

Running
-------
`npm start` - starts as daemon and writes log to `logfile.log`, you can try check it for troubleshooting.

`./cli --help` - get some help

`./cli add <url>` - add new torrent eg: `./cli add http://rutracker.org/forum/viewtopic.php?t=3467180`

`./cli list` - lists torrents the app watching

`./cli check` - check torrents right now

Note: if you want to delete torrent - just remove it from transmission