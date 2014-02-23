trackerApp = angular.module('trackerApp', ['trackerServices', 'trackerFilters', 'ui.bootstrap', 'ngAnimate'])

class ErrorHandler
  constructor: (@$timeout) ->
    @errors = []

  add: (error) ->
    return unless error.code

    @errors.push error
    @$timeout =>
      @remove error
    , 3000



  remove: (error) ->
    index = @errors.indexOf(error)
    if index > -1
      @errors.splice index, 1



trackerApp.service 'errorHandler', ['$timeout', ErrorHandler]

trackerApp.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.responseInterceptors.push ['$q', 'errorHandler', ($q, errorHandler) ->
    ($promise) ->

      $promise.catch (response) ->
        errorHandler.add response.data
        $q.reject response
  ]
]

class TrackerListCtl
  constructor: ($scope, Torrent, errorHandler) ->
    $scope.errors = errorHandler.errors

    $scope.torrents = []
    $scope.torrents = Torrent.query()

    # $scope.actions = 
    #   check: "Check now"
    #   delete: "Delete"

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

trackerApp.controller 'TrackerListCtl', ['$scope', 'Torrent', 'errorHandler', TrackerListCtl]