@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This deals with the Upload All action events.

  currentDeferred = []
  currentIndices = []

  API =
    uploadAll: ->
      console.log "uploadqueue uploadAll"

  App.commands.setHandler "uploadqueue:upload:all", ->
    API.uploadAll()
