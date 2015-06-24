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
      console.log "updated flow with page numbers", App.request('flow:current').map (step) -> "id: #{step.get('id')}, page: #{step.get('page')}, condition: #{step.get('condition')}"
      new SurveyMultipromptApp.Show.Controller
        page: page
        surveyId: surveyId

    goPrev: (surveyId) ->
      try
        prevPage = App.request "surveytracker:page:previous"
        # surveytracker:page:previous throws an exception if there is no previous page.

        # This needs to be triggered on each displaying step when navigating backwards
        # and the validation succeeds.
        # App.vent.trigger "survey:step:goback", surveyId, stepId

        App.navigate "surveymulti/#{surveyId}/page/#{prevPage}", { trigger: true }

      catch e
        # There is no previous page.
        App.execute "dialog:confirm", "Do you want to exit the #{App.dictionary('page','survey')}?", =>
          App.vent.trigger "survey:exit", surveyId

    goNext: (surveyId) ->
      nextPage = App.request "surveytracker:page:next", page
      # call the Router method without updating the URL
      @checkPage surveyId, nextPage

  App.addInitializer ->
    new SurveyMultipromptApp.Router
      controller: API
