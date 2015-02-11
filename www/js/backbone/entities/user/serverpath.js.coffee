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
      App.request "storage:get", 'serverpath', ((result) =>
        # serverpath is retrieved from raw JSON.
        console.log 'serverpath retrieved from storage'
        currentServer = new Entities.ServerPath result
      ), =>
        console.log 'serverpath not retrieved from storage'
        currentServer = new Entities.ServerPath
          path: App.request('serverlist:default')

    updateServer: (newPath) ->
      # remove trailing slash if it exists
      slash = /\/$/g
      newPath = newPath.replace(slash, "").trim()
      console.log 'newPath', newPath
      currentServer.set {path: newPath }, { validate: true }
      App.execute "storage:save", 'serverpath', currentServer.toJSON(), =>
        console.log "serverpath entity API.updateServer success"

    clear: ->
      # Don't reset current server if they log out - next time the app loads
      # it will refresh the server properly.
      App.execute "storage:clear", 'serverpath', ->
        console.log 'serverpath erased'
        App.vent.trigger "serverpath:cleared"

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "serverpath:entity", ->
    currentServer

  App.reqres.setHandler "serverpath:current", ->
    currentServer.get 'path'

  App.commands.setHandler "serverpath:update", (newPath) ->
    API.updateServer newPath

  App.vent.on "credentials:cleared", ->
    API.clear()

  Entities.on "start", ->
    API.init()
