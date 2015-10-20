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
