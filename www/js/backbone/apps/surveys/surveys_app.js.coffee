@Ohmage.module "SurveysApp", (SurveysApp, App, Backbone, Marionette, $, _) ->

  class SurveysApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "surveys/:campaign_id": "single"
      "surveys": "all"

  API =
    all: ->
      App.vent.trigger "nav:choose", "Surveys"
      new SurveysApp.List.Controller
        campaign_id: false
    single: (campaign_id) ->
      App.vent.trigger "nav:choose", "Surveys"
      new SurveysApp.List.Controller
        campaign_id: campaign_id

  App.addInitializer ->
    new SurveysApp.Router
      controller: API

  App.vent.on "survey:list:campaign:selected", (model) ->
    App.navigate model.get('url'), { trigger: true }
  
  App.vent.on "survey:list:running:clicked", (model) ->
    App.navigate "survey/#{model.get 'id'}", { trigger: true }

  App.vent.on "survey:list:stopped:clicked", (model) ->
    # Trigger the confirmation box for removing the ghosted campaign.
    campaign_urn = App.request "survey:saved:urn", model.get('id')
    App.execute "campaign:ghost:remove", campaign_urn, model.get('status')
