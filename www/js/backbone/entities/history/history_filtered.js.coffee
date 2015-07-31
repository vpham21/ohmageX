@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryFiltered entity is a decorator for History,
  # allowing history entries to be filtered into different parts based on their
  # attributes, such as bucket.

  class Entities.UserHistoryFiltered extends Entities.UserHistoryEntries
    initialize: (options) ->
      @entries = options
      @_meta = {}

      @listenTo @entries, "reset", ->
        @where @_currentCriteria

      @listenTo @entries, "sync:stop", ->
        @trigger "filter:bucket:clear"
        @where()

      @listenTo @entries, "remove", ->
        @remove model

    meta: (prop, value) ->
      if value is undefined
        return @_meta[prop]
      else
        @_meta[prop] = value

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

