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
  