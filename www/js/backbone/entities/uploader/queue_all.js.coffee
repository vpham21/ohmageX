@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This deals with the Upload All action events.

  currentDeferred = []
  currentIndices = []

  API =
    uploadAll: (queue) ->
      console.log "uploadqueue uploadAll"
      # save current queue length.
      oldLength = queue.length

  App.commands.setHandler "uploadqueue:upload:all", ->
    queue = App.request 'uploadqueue:entity'

    API.uploadAll queue
