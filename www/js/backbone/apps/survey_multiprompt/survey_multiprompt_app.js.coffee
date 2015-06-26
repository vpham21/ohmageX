@Ohmage.module "SurveyMultipromptApp", (SurveyMultipromptApp, App, Backbone, Marionette, $, _) ->

  class SurveyMultipromptApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "surveymulti/:surveyId/page/:page": "checkPage"
      "surveymulti/:surveyId/aftersubmit": 'afterSubmit'

  API =
    checkPage: (surveyId, page) ->
      console.log "checkPage", page

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
      console.log "updated flow with page numbers", App.request('flow:current').map (step) -> "\nid: #{step.get('id')}, page: #{step.get('page')}, condition: #{step.get('condition')}, status: #{step.get('status')}"
      new SurveyMultipromptApp.Show.Controller
        page: page
        surveyId: surveyId

    afterSubmit: (surveyId) ->
      # get the current flow's afterSubmit page number
      try
        @checkPage surveyId, App.request("flow:page:aftersubmit:page")
      catch
        # Redirect to the start of the survey
        # if attempting to get the aftersubmit page number throws an error
        App.navigate "survey/#{surveyId}", trigger: true

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

  App.on "before:start", ->

    if App.custom.functionality.multi_question_survey_flow is true
      console.log 'set app listeners here'

