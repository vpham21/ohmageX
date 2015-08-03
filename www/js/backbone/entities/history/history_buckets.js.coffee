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

      if @entries? and @entries.length > 0 and @entries instanceof Entities.UserHistoryEntries
        # get an array that contains only unique buckets.
        # pass `true` for isSorted param of `uniq` to speed it up.
        uniqueBuckets = _.chain(entries.toJSON()).pluck('bucket').uniq(true).value()
        result = result.concat uniqueBuckets.map (bucket) =>
          return {
            name: bucket
          }

      result

    chosenName: ->
      (@findWhere(chosen: true) or @first()).get('name')

  API =
    init: ->
      currentBuckets = new Entities.UserHistoryBucketsNav [], parse: true
      currentBuckets.chooseByName 'All'
    getBuckets: (entries) ->
      currentBuckets = new Entities.UserHistoryBucketsNav entries, parse: true
      if entries.length is 0
        currentBuckets.reset(null, parse: true)
      currentBuckets

  App.on "before:start", ->
    # TODO: later need to add an event to populate this dropdown after
    # history entries are retrieved from local storage.
    API.init()

  App.reqres.setHandler "history:selector:buckets", (entries) ->
    API.getBuckets entries
