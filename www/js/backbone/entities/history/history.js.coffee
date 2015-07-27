@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Entity generates the user's saved response history.

  currentHistory = false

  class Entities.UserHistoryResponse extends Entities.Model

  class Entities.UserHistoryResponsesByCampaign extends Entities.Collection
    model: Entities.UserHistoryResponse
    url: ->
      "#{App.request("serverpath:current")}/app/survey_response/read"

  class Entities.UserHistoryResponses extends Entities.Collection
    model: Entities.UserHistoryResponse

  API =
    init: ->
      currentHistory = new Entities.UserHistoryResponses
    fetchHistory: (campaign_urns) ->
      App.vent.trigger 'loading:show', "Fetching Responses..."
      campaignCollections = []
      responseFetchSuccess = []

      myData =
        # add start date - 3 months ago
        # if start date, end date is also required
        client: App.client_string
        column_list: "urn:ohmage:special:all"
        prompt_id_list: "urn:ohmage:special:all"
        output_format: "json-rows"
        user_list: App.request "credentials:username"
      myData = _.extend(myData, App.request("credentials:upload:params"))
    getHistory: ->
      if currentHistory.length < 1
        # fetch all history from the server,
        # because our current version is empty
        campaign_urns = App.request 'surveys:saved:campaign_urns'
        if campaign_urns.length is 0 then return false

      else
        # just return the collection
        currentHistory

  App.reqres.on "history:responses", ->
    API.getHistory()

  App.on "before:start", ->
    API.init()
