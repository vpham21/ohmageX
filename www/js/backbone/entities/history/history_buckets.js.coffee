@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Buckets Entity manages the buckets for user history.

  currentBuckets = false

  class Entities.UserHistoryBucketsNav extends Entities.NavsCollection
    initialize: (models) ->
      @entries = models

      # only create this listener if entries is an actual Collection.
      if @entries instanceof Entities.UserHistoryEntries
        @listenTo @entries, "sync:stop reset", =>
          @reset @entries, parse: true

    parse: (entries) ->

      # prepend default "All".
      result = [
            name: 'All'
          ]

      result

    chosenName: ->
      (@findWhere(chosen: true) or @first()).get('name')

  API =
    init: ->
      currentBuckets = new Entities.UserHistoryBucketsNav [], parse: true
      currentBuckets.chooseByName 'All'
  App.on "before:start", ->
    # TODO: later need to add an event to populate this dropdown after
    # history entries are retrieved from local storage.
    API.init()

