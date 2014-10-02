@Ohmage.module "SurveyApp", (SurveyApp, App, Backbone, Marionette, $, _) ->

  class SurveyApp.Router extends Marionette.AppRouter
    appRoutes:
      "survey/:id": "show"
    
  API =
    show: (id) ->
      console.log 'surveyApp show'

      $mySurveyXML = App.request "survey:xml", id # gets the jQuery Survey XML by ID
      # initialize both the flow and response objects with jQuery Survey XML
      App.execute "flow:init", $mySurveyXML
      App.execute "responses:init", $mySurveyXML

      firstId = App.request "flow:id:first"

      App.navigate "survey/#{id}/step/#{firstId}", trigger: true

  App.addInitializer ->
    new SurveyApp.Router
      controller: API

  App.commands.setHandler "survey:exit", (surveyId) ->
    App.execute "flow:destroy"
    App.execute "responses:destroy"
    App.navigate Routes.dashboard_route(), { trigger: true }