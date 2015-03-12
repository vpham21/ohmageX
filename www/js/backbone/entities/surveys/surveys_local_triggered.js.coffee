@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This saves and restores locally triggered surveys for a user.
  # This is separate from the system Notifications; triggered
  # surveys are saved locally.

  currentTriggered = false

  class Entities.SurveyTriggered extends Entities.Model

  class Entities.SurveysTriggered extends Entities.Collection
    model: Entities.SurveyTriggered

  API =
    init: ->
      App.request "storage:get", 'surveys_triggered', ((result) =>
        # customChoice is retrieved from raw JSON.
        console.log 'triggered surveys retrieved from storage'
        currentTriggered = new Entities.SurveysTriggered result
      ), =>
        console.log 'triggered surveys not retrieved from storage'
        currentTriggered = false

    exists: (surveyId) ->
      currentTriggered and currentTriggered.where(surveyId: surveyId).length > 0

  App.reqres.setHandler "surveys:local:triggered:entity", ->
    currentTriggered

  App.reqres.setHandler "surveys:local:triggered:exists", (surveyId) ->
    API.exists surveyId
  Entities.on "start", ->
    API.init()
