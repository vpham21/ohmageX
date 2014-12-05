@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This deals with the Upload All action events.

  currentDeferred = []
  currentIndices = []

  API =
    uploadAll: (queue) ->
      console.log "uploadqueue uploadAll"
      # save current queue length.
      oldLength = queue.length
      # map each item in the queue to a new Array,
      # containing Deferred objects.

      currentDeferred = []
      currentIndices = []

      currentDeferred = queue.map( (item, key) ->
        currentIndices.push(item.get 'id')
        return new $.Deferred()
      )

  App.commands.setHandler "uploadqueue:upload:all", ->
    queue = App.request 'uploadqueue:entity'

    API.uploadAll queue
