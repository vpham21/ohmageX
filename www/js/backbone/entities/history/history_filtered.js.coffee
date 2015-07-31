@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryFiltered entity is a decorator for History,
  # allowing history entries to be filtered into different parts based on their
  # attributes, such as bucket.

  class Entities.UserHistoryFiltered extends Entities.UserHistoryEntries
    initialize: (options) ->
      @entries = options
      @_meta = {}

    meta: (prop, value) ->
      if value is undefined
        return @_meta[prop]
      else
        @_meta[prop] = value

