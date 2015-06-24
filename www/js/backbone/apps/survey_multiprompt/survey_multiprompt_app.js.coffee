@Ohmage.module "SurveyMultipromptApp", (SurveyMultipromptApp, App, Backbone, Marionette, $, _) ->

  class SurveyMultipromptApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "surveymulti/:surveyId/page/:page": "checkPage"
  API =
    checkPage: (surveyId, page) ->
      console.log "checkPage #{page}"

      # Redirect to the start of the survey
      # if survey isn't initialized before proceeding.
      if not App.request "flow:init:status"
        App.navigate "survey/#{surveyId}", trigger: true
        return false

      App.execute "surveytracker:page:set", page

      @showPage surveyId, page

    showPage: (surveyId, page) ->
      # update URL without triggering the Router
      App.navigate "surveymulti/#{surveyId}/page/#{page}"
      console.log "updated flow with page numbers", App.request('flow:current').toJSON()
      new SurveyMultipromptApp.Show.Controller
        page: page
        surveyId: surveyId

  App.addInitializer ->
    new SurveyMultipromptApp.Router
      controller: API
