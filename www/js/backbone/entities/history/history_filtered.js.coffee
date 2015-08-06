@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryFiltered entity is a decorator for History,
  # allowing history entries to be filtered into different parts based on their
  # attributes, such as bucket.

  class Entities.UserHistoryFiltered extends Entities.UserHistoryEntries
    initialize: (options) ->
      @entries = options
      @_meta = {}
      @_currentCriteria = {}

      @listenTo @entries, "reset", ->
        @where @_currentCriteria

      @listenTo @entries, "sync:stop", ->
        @where()

      @listenTo @entries, "remove", (model) ->
        @remove model

      @listenTo @, "filter:set", (filterType, value) =>
        @_currentCriteria[filterType] = value
        @where @_currentCriteria

      @listenTo @, "filter:reset", (filterType) =>
        delete @_currentCriteria[filterType]
        @where @_currentCriteria

    where: (criteria) ->
      if criteria
        if criteria.bucket?
          items = @entries.filter (entry) ->
            criteria.bucket is entry.get 'bucket'
          @meta('bucketFilter', true)
        else
          @meta('bucketFilter', false)
      else
        @meta('bucketFilter', false)
        items = @entries.models
      console.log 'criteria', criteria
      @_currentCriteria = criteria

      @reset items

  API =
    getFiltered: (entries) ->
      filtered = new Entities.UserHistoryFiltered entries
      if entries.length > 0
        # repopulates the list if our history list starts out not empty,
        # such as when navigating back to the history list when
        # the list has already been fetched.
        entries.trigger 'reset'
      else
        # For some reason this version of filtering
        # populates the filtered collection with a single
        # model, even if `entries` is actually empty.
        # Not sure what causes this, but resetting the
        # collection before returning it will
        # prevent it from being initialized with an invalid
        # model.
        filtered.reset()
      filtered

  App.reqres.setHandler "history:entries:filtered", (entries) ->
    console.log 'history:filtered', entries
    API.getFiltered entries
