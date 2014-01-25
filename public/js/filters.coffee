trackerFilters = angular.module('trackerFilters', [])

trackerFilters.filter 'torrent_title', ->
  (torrent) ->
    torrent.tracker_title or torrent.torrent_url