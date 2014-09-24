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

      console.log 'id', id
      console.log 'first', first

  App.addInitializer ->
    new SurveyStepsApp.Router
      controller: API
  