@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The HistoryMediaQueue is a queue for history media downloads.

  class Entities.HistoryMediaQueueItem extends Entities.Model
    defaults:
      fetched: false

  class Entities.HistoryMediaQueue extends Entities.Collection
    model: Entities.HistoryMediaQueueItem

  currentQueue = []

