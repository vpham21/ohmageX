@Ohmage.module "SurveyStepsApp", (SurveyStepsApp, App, Backbone, Marionette, $, _) ->

  class SurveyStepsApp.Router extends Marionette.AppRouter
    appRoutes:
      "survey/:id/step/:stepId": "checkStep"

  API =
    checkStep: (id, stepId) ->
      console.log "checkStep #{stepId}"

      # Redirect to the start of the survey 
      # if survey isn't initialized before proceeding.
      # TODO: persist currentFlow in localStorage for refresh
      if not App.request "flow:init:status" 
        App.navigate "survey/#{id}", trigger: true
        return false

      isPassed = App.request "flow:condition:check", stepId

      if isPassed
        @showStep stepId
      else
        nextId = App.request "flow:id:next", stepId
        App.navigate "survey/#{id}/step/#{nextId}", { trigger: true }

    showStep: (stepId) ->
      new SurveyStepsApp.Show.Controller
        stepId: stepId

  App.addInitializer ->
    new SurveyStepsApp.Router
      controller: API
  