@Ohmage.module "SurveyApp", (SurveyApp, App, Backbone, Marionette, $, _) ->

  class SurveyApp.Router extends Marionette.AppRouter
    before: ->
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        if !confirm('do you want to exit the survey?')
          # They don't want to exit the survey, cancel.
          # Move the history to its previous URL.
          App.historyPrevious()
          return false
    appRoutes:
      "survey/:id": "show"

  API =
    show: (id) ->
      console.log 'surveyApp show'

      $mySurveyXML = App.request "survey:saved:xml", id # gets the jQuery Survey XML by ID
      # initialize both the flow and response objects with jQuery Survey XML

      try
        App.execute "flow:init", $mySurveyXML
        App.execute "responses:init", $mySurveyXML
      catch Error
        # flow was already initialized. This happens if
        # someone navigates backwards out of a survey
        # via either URL or via hitting the Back Button.
        # this cleans up and exits the survey properly.
        console.log Error
        App.vent.trigger "survey:exit"
        return false

      App.vent.trigger "survey:start", id

      firstId = App.request "flow:id:first"

      App.navigate "survey/#{id}/step/#{firstId}", trigger: true

  App.addInitializer ->
    new SurveyApp.Router
      controller: API

  App.vent.on "survey:exit", ->
    App.navigate Routes.dashboard_route(), { trigger: true }
