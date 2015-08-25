@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # HistoryResponses manages responses returned from a single
  # history Entry.

  class Entities.UserHistoryResponse extends Entities.Model
    defaults:
      media_url: false

