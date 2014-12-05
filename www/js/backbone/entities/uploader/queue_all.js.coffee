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

      # tracking indices in a separate array.
      # Required if using Coffeescript splats to pass
      # arguments to Deferred (which map to .apply())
      # can't use an "associative" array
      $.when( currentDeferred... ).done =>
        @whenComplete(oldLength)

    whenComplete: (oldLength) ->
      newLength = App.request 'uploadqueue:length'
      App.vent.trigger "uploadqueue:all:complete"
      console.log "whenComplete queue", newLength
      if newLength is 0
        # success, show success notice
        App.execute "notice:show",
          data:
            title: "Upload Success"
            description: "All responses uploaded successfully."
            showCancel: false
      else
        # some failed, use oldLength
        App.execute "notice:show",
          data:
            title: "Upload Failure"
            description: "#{newLength} out of #{oldLength} responses failed to upload."
            showCancel: false
  App.commands.setHandler "uploadqueue:upload:all", ->
    queue = App.request 'uploadqueue:entity'

    API.uploadAll queue
