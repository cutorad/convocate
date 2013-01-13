$ = require('jquery')
angular = require 'angular'

app = angular.module 'convocate', []

app.controller 'ChatController', ['$scope', ($scope) ->
  $scope.connected = false
  $scope.unauthenticated = false

  $scope.username = null
  $scope.users = []
  $scope.chats = []

  socket = io.connect()

  socket.on 'error', (reason) ->
    $scope.unauthenticated = true
    $scope.$apply()

  socket.on 'connect', ->
    $scope.connected = true
    $scope.$apply()

  socket.on 'room:join', (username) ->
    $scope.users.push username
    $scope.chats.push type: 'entrance', username: username
    $scope.$apply()

  socket.on 'room:leave', (username) ->
    index = $scope.users.indexOf(username)
    $scope.users.splice(index, 1) if index != -1
    $scope.chats.push type: 'exit', username: username
    $scope.$apply()

  socket.on 'room:chat', (chat) ->
    $scope.chats.push chat
    $scope.$apply()

  socket.on 'room:people', (data) ->
    $scope.username = data.identity
    $scope.users = data.users
    $scope.$apply()

  $scope.submitMessage = ->
    socket.emit 'room:chat', $scope.message
    $scope.chats.push
      username: $scope.username
      message: $scope.message
    $scope.message = ''
]

app.directive 'editbox', ->
  link: (scope, elem, attrs) ->
    elem.on 'keydown', (evt) ->
      if evt.which == 13 && !evt.shiftKey
        evt.preventDefault()
        scope.$apply attrs.editboxEnter

app.filter 'sanitize', ->
  (str) ->
    return "" unless str?
    str.replace(/</g, '&lt;')

app.filter 'nl2br', ->
  (str) ->
    return "" unless str?
    str.replace(/(\n)|(&#10;)/g, "<br>\n")
