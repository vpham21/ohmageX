@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Entity generates the user's saved response history.

  currentHistory = false

  class Entities.UserHistoryEntry extends Entities.Model

  class Entities.UserHistoryEntriesByCampaign extends Entities.Collection
    model: Entities.UserHistoryEntry
    url: ->
      "#{App.request("serverpath:current")}/app/survey_response/read"
    addSorting: (results) ->
      sortParams = {}
      if App.custom.functionality.history_bucketby_first_prompt
        for prop in responses
          # get first response
          firstResponse = responses[prop]
          break
        sortParams.bucket = firstResponse.prompt_response
      else
        sortParams.bucket = results.date

      sortParams.sortIndex = "#{sortParams.bucket}:#{results.utc_timestamp}"

      _.extend(results, sortParams)

    parse: (response, options) ->
      # parse JSON into individual responses with campaign metadata


      # there are no responses for the campaign at all.
      if response.data.length is 0 then return []


      # Only want to create a new Entry for a valid entry.
      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.

      campaignEntries = _.chain(response.data).map((value, key) =>
        # possible TODO: add return false the entry is somehow invalid.
        results = {
          id: value.survey_key
          date: value.date
          timestamp: value.timestamp
          timezone: value.timezone
          utc_timestamp: value.utc_timestamp
          campaign_urn: options.campaign.id
          survey_id: value.survey_id
          location:
            location_status: value.location_status
            location_timestamp: value.location_timestamp
            location_timezone: value.location_timezone
            latitude: value.latitude
            longitude: value.longitude
            provider: value.provider
            accuracy: value.accuracy
          campaign: options.campaign.toJSON()
          survey:
            title: value.survey_title
            description: value.survey_description
          responses: value.responses
        }
        return @addSorting(results)
      ).filter((result) -> !!result).value()
      campaignEntries

  class Entities.UserHistoryEntries extends Entities.Collection
    model: Entities.UserHistoryEntry
    comparator: "sortIndex"

  API =
    init: ->
      currentHistory = new Entities.UserHistoryEntries
    fetchHistory: (campaign_urns) ->
      App.vent.trigger 'loading:show', "Fetching History..."
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

      _.each campaign_urns, (campaign_urn) ->
        myData.campaign_urn = campaign_urn
        myCampaign = new Entities.UserHistoryEntriesByCampaign
        campaignCollections.push myCampaign

        myCampaign.fetch
          reset: true
          type: "POST"
          data: myData
          campaign: App.request "campaign:entity", campaign_urn
          success: (collection, response, options) =>
            if response.result isnt "failure"
              responseFetchSuccess.push true
            else
              responseFetchSuccess.push false

          error: (collection, response, options) =>
            responseFetchSuccess.push false
            App.execute "dialog:alert", "Network error fetching history."

      currentHistory._fetch = new $.Deferred()

      App.execute "when:fetched", campaignCollections, =>
        if _.contains(responseFetchSuccess, false)
          # there was an error while fetching one of the campaign's history entries
          App.vent.trigger "history:entries:fetch:error"
        else
          # no errors, merge all of the fetched collections into the main history collection.
          _.each campaignCollections, (collection) =>
            currentHistory.add collection.toJSON()

          # TODO: in the bucket entity, we generate new buckets based on this new currentHistory

          App.vent.trigger "history:entries:fetch:success", currentHistory
        # resolve the fetch handler.
        currentHistory._fetch.resolve()

    getHistory: ->
      if currentHistory.length < 1
        # fetch all history from the server,
        # because our current version is empty
        campaign_urns = App.request 'campaigns:saved:urns'
        if campaign_urns.length is 0 then return false

        @fetchHistory campaign_urns
      else
        # just return the collection
        currentHistory
    removeByCampaign: (campaign_urn) ->
      currentHistory.remove currentHistory.where(campaign_urn: campaign_urn)
    clear: ->
      currentHistory = false


  App.reqres.setHandler "history:entries", ->
    API.getHistory()

  App.reqres.setHandler "history:entries:list", ->
    # no fetching, just retrieve the history
    currentHistory

  App.on "before:start", ->
    API.init()

  App.commands.setHandler "history:sync", ->
    campaign_urns = App.request 'campaigns:saved:urns'
    if campaign_urns.length is 0 then return false

    API.fetchHistory campaign_urns

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    API.removeByCampaign campaign_urn

  App.vent.on "credentials:cleared", ->
    API.clear()
