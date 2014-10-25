@Ohmage.module "SurveysApp", (SurveysApp, App, Backbone, Marionette, $, _) ->

  class SurveysApp.Router extends Marionette.AppRouter
    before: ->
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        if confirm('do you want to exit the survey?')
          # reset the survey's entities.
          App.vent.trigger "survey:reset"
        else
          # They don't want to exit the survey, cancel.
          # Move the history to its previous URL.
          App.historyPrevious()
          return false
    appRoutes:
      "surveys/:campaign_id": "list"

  API =
    list: (campaign_id) ->
      App.vent.trigger "nav:choose", "Dashboard"
      new SurveysApp.List.Controller
        campaign_id: campaign_id

  App.addInitializer ->
    new SurveysApp.Router
      controller: API
  
  App.vent.on "survey:list:item:clicked", (model) ->
    App.navigate "survey/#{model.get 'id'}", { trigger: true }


  App.vent.on "survey:list:logout:clicked", ->
    console.log "survey:list:logout:clicked"
    if confirm 'Do you want to logout?'
      App.execute "credentials:logout"
