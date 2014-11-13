@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The ServerPath Entity contains the initializer for server configuration.
  # Used when the user selects a server.
  currentServer = false

  class Entities.ServerPath extends Entities.ValidatedModel
    validate: (attrs, options) ->
      # defining a placeholder value here,
      # so a property can be passed into the rulesMap.
      attrs.properties =
        httpHost: true
      attrs.response = attrs.path
      myRulesMap =
        httpHost: 'httpHost'
      super attrs, options, myRulesMap

  API =
    init: ->
      currentServer = new Entities.ServerPath
        path: 'https://test.mobilizingcs.org'

    updateServer: (newPath) ->
      # remove trailing slash if it exists
      slash = /\/$/g
      newPath = newPath.replace(slash, "").trim()
      console.log 'newPath', newPath
      currentServer.set {path: newPath }, { validate: true }
      console.log 'currentServer', currentServer.toJSON()

  App.reqres.setHandler "serverpath:entity", ->
    currentServer

  App.reqres.setHandler "serverpath:current", ->
    currentServer.get 'path'

  App.commands.setHandler "serverpath:update", (newPath) ->
    API.updateServer newPath

  Entities.on "start", ->
    API.init()