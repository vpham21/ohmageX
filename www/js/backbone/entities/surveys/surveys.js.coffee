@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Surveys Entity deals with data relating to all saved
  # surveys.

  currentSurveysSaved = false

  class Entities.SurveySaved extends Entities.Model
    defaults:
      status: 'running' # All surveys are running when first created

  class Entities.SurveysSaved extends Entities.Collection
    model: Entities.SurveySaved
    url: ->
      "#{App.request("serverpath:current")}/app/campaign/read"
    parse: (response, options) ->
      console.log 'options in parse', options
      urn = options.data.campaign_urn_list
      campaignXML = response.data[urn].xml
      $surveys = @getSurveyXML campaignXML
      @parseSurveysXML $surveys, urn, campaignXML
    getSurveyXML: (rawXML) ->
      $XML = $( $.parseXML(rawXML) )
      $XML.find 'survey'
    parseSurveysXML: ($surveysXML, urn, campaignXML) ->
      _.map($surveysXML, (survey) ->
        $survey = $(survey)
        myId = $survey.tagText('> id')
        {
          id: "#{urn}:#{myId}"
          server_id: myId
          title: $survey.tagText('title')
          description: $survey.tagText('description')
          xmlStr: my$XmlToString($survey).trim()
          campaign_urn: urn
        }
      )

  API =
    init: ->
      App.request "storage:get", 'saved_surveys', ((result) =>
        # user saved surveys retrieved from raw JSON.
        console.log 'user saved surveys retrieved from storage'
        currentSurveysSaved = new Entities.SurveysSaved result
        App.vent.trigger('surveys:saved:load:complete')
      ), =>
        console.log 'user saved surveys not retrieved from storage'
        currentSurveysSaved = new Entities.SurveysSaved
        App.vent.trigger('surveys:saved:load:complete')

    getSurveys: (campaign_urn) ->
      console.log campaign_urn
      credentials = App.request "credentials:current"
      App.vent.trigger "loading:show", "Saving campaign..."
      currentSurveysSaved.fetch
        reset: false
        remove: false # merge any newly fetched surveys with existing ones based on ID
        type: 'POST' # not RESTful but the 2.0 API requires it
        data:
          user: credentials.get 'username'
          password: credentials.get 'password'
          client: 'ohmage-mwf-dw-browser'
          output_format: 'long'
          campaign_urn_list: campaign_urn
        success: (collection, response, options) =>
          console.log 'surveys fetch success', response, collection
          @updateLocal( =>
            App.vent.trigger 'surveys:saved:campaign:fetch:success', options.data.campaign_urn_list
          )
          App.vent.trigger "loading:hide"
        error: (collection, response, options) =>
          console.log 'surveys fetch error'
          App.vent.trigger 'surveys:saved:campaign:fetch:error', options.data.campaign_urn_list
          App.vent.trigger "loading:hide"
    getCampaignSurveys: (urn) ->
      surveys = currentSurveysSaved.where 
        campaign_urn: urn
      new Entities.SurveysSaved surveys
    removeSurveys: (urn) ->
      currentSurveysSaved.remove currentSurveysSaved.where(campaign_urn: urn)
      @updateLocal( =>
        App.vent.trigger 'surveys:saved:campaign:remove:success', urn
      )
    updateLocal: (callback) ->
      # update localStorage index saved_surveys with the current version of campaignsSaved entity
      App.execute "storage:save", 'saved_surveys', currentSurveysSaved.toJSON(), callback
    clear: ->
      currentSurveysSaved = new Entities.SurveysSaved

      App.execute "storage:clear", 'saved_surveys', ->
        console.log 'user saved surveys erased'
        App.vent.trigger "surveys:saved:cleared"
    getSurveyAttr: (id, key) ->
      mySurvey = currentSurveysSaved.get id
      mySurvey.get key
    getSurveyXML: (id) ->
      # this fetches a single survey's xml by it's ID.
      xmlStr = @getSurveyAttr id, 'xmlStr'
      $( $.parseXML(xmlStr) )

  App.reqres.setHandler "survey:saved:xml", (id) ->
    # note the survey's id is formatted `campaign_urn:server_id`
    API.getSurveyXML id

  App.reqres.setHandler "survey:saved:urn", (id) ->
    # note the survey's id is formatted `campaign_urn:server_id`
    API.getSurveyAttr id, 'campaign_urn'

  App.reqres.setHandler "survey:saved:server_id", (id) ->
    # note the survey's id is formatted `campaign_urn:server_id`
    API.getSurveyAttr id, 'server_id'

  App.on "before:start", ->
    API.init()

  App.vent.on "campaign:saved:add", (campaign_urn) ->
    API.getSurveys campaign_urn

  App.vent.on "campaign:saved:remove", (campaign_urn) ->
    API.removeSurveys campaign_urn

  App.commands.setHandler "debug:surveys:saved:campaign:fetch", (campaign_urn) ->
    API.getSurveys campaign_urn

  App.commands.setHandler "debug:surveys:saved:campaign:remove", (campaign_urn) ->
    API.removeSurveys campaign_urn

  App.commands.setHandler "debug:surveys:modify", (id, JSON) ->
    mySurveys = currentSurveysSaved.get id
    mySurveys.set JSON
    console.log 'modified surveys', mySurveys.toJSON()

  App.reqres.setHandler "surveys:saved", ->
    currentSurveysSaved

  App.reqres.setHandler "surveys:saved:campaign", (campaign_urn) ->
    API.getCampaignSurveys campaign_urn

  App.vent.on "credentials:cleared", ->
    API.clear()
