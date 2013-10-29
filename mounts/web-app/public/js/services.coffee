trackerServices = angular.module('trackerServices', ['ngResource'])

trackerServices.factory "Torrent", [
  '$resource'
  ($resource) ->
    $resource("torrents/:torrentId", {}, {

    })
]