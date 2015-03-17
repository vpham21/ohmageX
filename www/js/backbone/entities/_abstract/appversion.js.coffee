@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Version entity.
  # This pertains to tracking the current app version.

  class Entities.AppVersion extends Entities.Model

  storedVersion = false

  API =
    init: ->
      App.request "storage:get", 'app_version', ((result) =>
        # saved version retrieved from raw JSON.
        console.log 'saved version retrieved from storage'
        storedVersion = new Entities.AppVersion result
        App.vent.trigger "appversion:saved:init:success"
        API.checkForUpdate()
      ), =>
        console.log 'saved version not retrieved from storage'
        storedVersion = new Entities.AppVersion
          version: App.version
        App.vent.trigger "appversion:saved:init:failure"

        @updateLocal(=>
          App.vent.trigger "appversion:firstrun"
        )

    updateLocal: (callback) ->
      # update localStorage index version with the current version
      App.execute "storage:save", 'app_version', storedVersion.toJSON(), callback

    checkForUpdate: ->
      if App.version isnt storedVersion.get('version')
        oldVersion = storedVersion.get('version')
        storedVersion = new Entities.AppVersion
          version: App.version

        @updateLocal( =>
          App.vent.trigger "loading:show", "Upgrading, clearing settings..."
          setTimeout (=>
            App.vent.trigger "loading:hide"
            App.vent.trigger "appversion:update", oldVersion
          ), 3000
        )

  App.on "before:start", ->
    API.init()
