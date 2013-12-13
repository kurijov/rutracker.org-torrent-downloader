trackerApp = angular.module('trackerApp', ['trackerServices', 'ui.bootstrap'])

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
      newTorrent = new Torrent url: $scope.torrentUrl, tracker_title: $scope.torrentUrl
      
      $scope.torrents.push newTorrent
      $scope.torrentUrl = ""

      newTorrent.$save().catch (error) ->
        $scope.torrents.splice $scope.torrents.indexOf(newTorrent), 1


# class DropdownCtrl
#   constructor: ($scope) ->
#     $scope.items = [
#       {title: "Check now", action: 'check'}
#       {title: "Delete", action: 'delete'}
#     ]

trackerApp.controller 'TrackerListCtl', ['$scope', 'Torrent', TrackerListCtl]
# trackerApp.controller 'DropdownCtrl', ['$scope', DropdownCtrl]