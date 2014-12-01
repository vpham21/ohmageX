@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This deals with the Upload All action.

  API =
    uploadAll: ->
      console.log "uploadqueue uploadAll"

  App.commands.setHandler "uploadqueue:upload:all", ->
    API.uploadAll()
