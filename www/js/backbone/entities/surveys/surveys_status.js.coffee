@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Surveys Status handles status changes and updates
  # for the SurveysSaved Entity

  API =
    changeCampaignSurveysStatus: (saved, urn, status) ->
      saved.each( (survey) ->
        if survey.get('campaign_urn') is urn and survey.get('status') isnt status
          console.log 'change survey status to'
          survey.set 'status', status
      )
      saved.trigger 'update:status:complete'
      console.log 'new saved', saved.toJSON()

  App.vent.on "campaign:user:status:saved", (id) ->
    API.changeCampaignSurveysStatus App.request("surveys:saved"), id, 'running'

  App.vent.on "campaign:user:status:ghost", (id, myStatus) ->
    API.changeCampaignSurveysStatus App.request("surveys:saved"), id, myStatus

  App.commands.setHandler "debug:surveys:saved:campaign:status:change", (campaign_urn, status) ->
    API.changeCampaignSurveysStatus App.request("surveys:saved"), campaign_urn, status
