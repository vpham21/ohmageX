@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The campaign Entity deals with data relating to a single campaign.

  class Entities.CampaignSurvey extends Entities.Model

  class Entities.CampaignSurveys extends Entities.Collection
    model: Entities.CampaignSurvey

  API =
    getSurveys: ->
      $surveysXML = App.request "xml:get", "survey"
      new Entities.CampaignSurveys @parseSurveysXML($surveysXML)

    parseSurveysXML: ($surveysXML) ->
      _.map($surveysXML, (survey) ->
        $survey = $(survey)
        {
          id: $survey.tagText('> id')
          title: $survey.tagText('title')
          description: $survey.tagText('description')
        }
      )

  App.reqres.setHandler "campaign:surveys", ->
    API.getSurveys()