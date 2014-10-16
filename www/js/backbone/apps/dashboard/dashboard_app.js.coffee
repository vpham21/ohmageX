@Ohmage.module "DashboardApp", (DashboardApp, App, Backbone, Marionette, $, _) ->

  class DashboardApp.Router extends Marionette.AppRouter
    appRoutes:
      "home": "list"
    
  API =
    show: ->
      App.vent.trigger "nav:choose", "Dashboard"
      new DashboardApp.Show.Controller

    list: ->
      App.vent.trigger "nav:choose", "Dashboard"
      new DashboardApp.List.Controller

  App.addInitializer ->
    new DashboardApp.Router
      controller: API
  
  App.vent.on "survey:list:item:clicked", (model) ->
    App.navigate "survey/#{model.get 'id'}", { trigger: true }


  App.vent.on "survey:list:logout:clicked", ->
    console.log "survey:list:logout:clicked"
    if confirm 'Do you want to logout?'
      App.execute "credentials:logout"
