@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The campaign Entity deals with data relating to a single campaign.

  currentSurveys = false

  class Entities.CampaignSurvey extends Entities.Model

  class Entities.CampaignSurveys extends Entities.Collection
    model: Entities.CampaignSurvey
    url: ->
      "#{App.request("serverpath:current")}/app/campaign/read"
    parse: (response, options) ->
      console.log options
      urn = options.data.campaign_urn_list
      campaignXML = response.data[urn].xml
      $surveys = @getSurveyXML campaignXML
      @parseSurveysXML $surveys
    getSurveyXML: (rawXML) ->
      $XML = $( $.parseXML(rawXML) )
      $XML.find 'survey'
    parseSurveysXML: ($surveysXML) ->
      _.map($surveysXML, (survey) ->
        $survey = $(survey)
        {
          id: $survey.tagText('> id')
          title: $survey.tagText('title')
          description: $survey.tagText('description')
          $xml: $survey
        }
      )

  API =
    getSurveys: (campaign_urn) ->
      console.log campaign_urn
      credentials = App.request "credentials:current"
      currentSurveys = new Entities.CampaignSurveys
      currentSurveys.fetch
        reset: true
        type: 'POST' # not RESTful but the 2.0 API requires it
        data:
          user: credentials.get 'username'
          password: credentials.get 'password'
          client: 'ohmage-mwf-dw-browser'
          output_format: 'long'
          campaign_urn_list: campaign_urn
        success: (collection, response, options) =>
          console.log 'surveys fetch success', response, collection
        error: (collection, response, options) =>
          console.log 'surveys fetch error'
      currentSurveys
    getSurveyXML: (id) ->
      mySurvey = currentSurveys.get id
      mySurvey.get '$xml'

  App.reqres.setHandler "campaign:surveys", (id) ->
    API.getSurveys id

  App.reqres.setHandler "campaign:survey:xml", (id) ->
    API.getSurveyXML id
