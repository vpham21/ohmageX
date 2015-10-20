@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This handles History Media Queue operations on all items.

  currentDeferred = []
  currentIndices = []

  API =
    downloadAll: (queue) ->
      console.log 'history media queue downloadAll'

      # map each item in the queue to a new Array,
      # containing Deferred objects.

      currentDeferred = []
      currentIndices = []

      currentDeferred = queue.map( (item, key) ->
        currentIndices.push(item.get 'id')
        return new $.Deferred()
      )

      $.when( currentDeferred... ).done =>
        @whenComplete()

      App.vent.trigger "history:media:queue:all:start"

      queue.each (item) ->
        itemId = item.get('id')
        context = item.get('context')

        if App.device.isNative
          App.execute "filemeta:fetch:auto", itemId, context
        else
          App.vent.trigger "filemeta:fetch:auto:success", itemId, context

    whenComplete: ->
      errorCount = App.request "history:media:queue:errors:count"
      myLength = App.request "history:media:queue:length"
      App.vent.trigger "history:media:queue:all:complete"
      if errorCount is 0
        # success, show success notice
        # App.execute "dialog:alert", "All History images and documents fetched successfully."
      else
        # some failed, use errorCount
        App.execute "dialog:alert", "Unable to fetch #{errorCount} out of #{myLength} images or documents in the History."

