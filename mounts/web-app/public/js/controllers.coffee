trackerApp = angular.module('trackerApp', [])

class TrackerListCtl
  constructor: ($scope, $http) ->
    $scope.torrents = []

    $http.get('list').success (data) ->
      $scope.torrents = data

    $scope.addTorrent = ->
      $http.post('add', {url: $scope.torrentUrl}).success (data) ->
        $scope.torrents.push data
      $scope.torrentUrl = ""






trackerApp.controller 'TrackerListCtl', ['$scope', '$http', TrackerListCtl]