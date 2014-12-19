@Ohmage.module "CampaignsApp", (CampaignsApp, App, Backbone, Marionette, $, _) ->

  class CampaignsApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "campaigns": "list"

  API =
    list: ->
      App.vent.trigger "nav:choose", "Campaigns"
      new CampaignsApp.List.Controller

  App.addInitializer ->
    new CampaignsApp.Router
      controller: API

  App.vent.on "campaign:list:navigate:clicked", (model) ->
    App.navigate "surveys/#{model.get 'id'}", { trigger: true }

  App.vent.on "campaign:list:save:clicked", (model) ->
    App.execute "campaign:save", model

  App.vent.on "campaign:list:unsave:clicked", (model, view, filterType) ->
    App.execute "dialog:confirm", "Are you sure you want to unsave this campaign?", (=>
      App.execute "campaign:unsave", model.get 'id'
      if filterType is 'saved' then view.destroy()
    )

  App.vent.on "campaign:list:ghost:remove:clicked", (model) ->
    console.log 'model', model
    App.execute "campaign:ghost:remove", model.get('id'), model.get('status')
