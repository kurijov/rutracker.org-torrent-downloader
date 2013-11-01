trackerServices = angular.module('trackerServices', ['ngResource'])

trackerServices.factory "Torrent", [
  '$resource'
  ($resource) ->
    $resource("torrents/:id", {}, {
      check: {method: 'get', url: 'torrents/check/:id', params: {id: '@id'}}
    })
]