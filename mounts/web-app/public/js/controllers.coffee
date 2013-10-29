trackerApp = angular.module('trackerApp', ['trackerServices'])

class TrackerListCtl
  constructor: ($scope, Torrent) ->
    $scope.torrents = []
    $scope.torrents = Torrent.query()

    $scope.addTorrent = ->
      newTorrent = new Torrent url: $scope.torrentUrl, tracker_title: $scope.torrentUrl
      
      $scope.torrents.push newTorrent
      $scope.torrentUrl = ""

      newTorrent.$save().catch (error) ->
        $scope.torrents.splice $scope.torrents.indexOf(newTorrent), 1



trackerApp.controller 'TrackerListCtl', ['$scope', 'Torrent', TrackerListCtl]