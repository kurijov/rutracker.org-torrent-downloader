trackerApp = angular.module('trackerApp', ['trackerServices', 'trackerFilters', 'ui.bootstrap'])

class TrackerListCtl
  constructor: ($scope, Torrent) ->
    $scope.torrents = []
    $scope.torrents = Torrent.query()

    $scope.actions = 
      check: "Check now"
      delete: "Delete"

    $scope.check = (index) ->     
      $scope.torrents[index].in_job = true
      $scope.torrents[index].$check()

    $scope.delete = (index) ->
      $scope.torrents[index].in_job = true
      $scope.torrents[index].$remove()
      $scope.torrents.splice index, 1

    $scope.addTorrent = ->
      newTorrent = new Torrent torrent_url: $scope.torrentUrl
      
      $scope.torrents.push newTorrent
      $scope.torrentUrl = ""

      newTorrent.$save().catch (error) ->
        $scope.torrents.splice $scope.torrents.indexOf(newTorrent), 1

trackerApp.controller 'TrackerListCtl', ['$scope', 'Torrent', TrackerListCtl]