trackerServices = angular.module('trackerServices', ['ngResource'])

trackerServices.factory "Torrent", [
  '$resource'
  ($resource) ->
    
    $resource("torrents/:id", {}, {
      check: {method: 'get', url: 'torrents/check/:id', params: {id: '@id'}}
      remove: {
        method: 'delete'
        url: 'torrents/:id'
        params: {id: '@id'}
      }
    })
]