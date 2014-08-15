@Ohmage.module "DashboardApp", (DashboardApp, App, Backbone, Marionette, $, _) ->

  class DashboardApp.Router extends Marionette.AppRouter
    appRoutes:
      "home": "show"
    
  API =
    show: ->
      App.vent.trigger "nav:choose", "Dashboard"
      new DashboardApp.Show.Controller

      
  App.addInitializer ->
    new DashboardApp.Router
      controller: API
  