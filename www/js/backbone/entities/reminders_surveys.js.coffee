@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders Surveys entity.
  # Uses surveys to generate a list for the Reminders Survey Selector.

  class Entities.ReminderSurvey extends Entities.Model

  class Entities.ReminderSurveys extends Entities.Collection
    model: Entities.ReminderSurvey

  API =

    getReminderSurveys: (surveys, surveyId) ->
      new Entities.ReminderSurveys surveys.map((survey) ->
        id: survey.get('id')
        title: survey.get('title')
        description: survey.get('description')
        campaign_urn: survey.get('campaign_urn')
        selected: survey.get('id') is surveyId
      )

  App.reqres.setHandler "reminders:surveys", (surveyId) ->
    API.getReminderSurveys App.request('surveys:saved'), surveyId
