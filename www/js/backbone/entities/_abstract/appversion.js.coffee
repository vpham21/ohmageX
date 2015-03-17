@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Version entity.
  # This pertains to tracking the current app version.

  class Entities.AppVersion extends Entities.Model


    updateLocal: (callback) ->
      # update localStorage index version with the current version
      App.execute "storage:save", 'app_version', storedVersion.toJSON(), callback

