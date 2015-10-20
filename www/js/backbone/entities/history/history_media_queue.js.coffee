@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryMediaQueue is a queue for history media downloads.

  class Entities.HistoryMediaQueueItem extends Entities.Model
    defaults:
      fetched: false

  class Entities.HistoryMediaQueue extends Entities.Collection
    model: Entities.HistoryMediaQueueItem

  currentQueue = []

  API =
    init: ->
      currentQueue = new Entities.HistoryMediaQueue

  App.on "before:start", ->
    API.init()


  App.reqres.setHandler "history:media:queue", ->
    currentQueue

  App.reqres.setHandler "history:media:queue:length", ->
    currentQueue.length

