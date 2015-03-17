@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Version entity.
  # This pertains to tracking the current app version.

  class Entities.AppVersion extends Entities.Model


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
