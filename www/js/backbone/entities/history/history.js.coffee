@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Entity generates the user's saved response history.

  currentHistory = false

  class Entities.UserHistoryResponse extends Entities.Model

  class Entities.UserHistoryResponsesByCampaign extends Entities.Collection
    model: Entities.UserHistoryResponse

  class Entities.UserHistoryResponses extends Entities.Collection
    model: Entities.UserHistoryResponse

  API =
    init: ->
      currentHistory = new Entities.UserHistoryResponses
  App.on "before:start", ->
    API.init()
