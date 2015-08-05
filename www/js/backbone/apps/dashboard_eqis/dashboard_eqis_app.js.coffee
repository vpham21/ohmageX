@Ohmage.module "DashboardeQISApp", (DashboardeQISApp, App, Backbone, Marionette, $, _) ->

  class DashboardeQISApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "dashboard": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "dashboardeqis"
      console.log 'DashboardeQISApp show'
      new DashboardeQISApp.Show.Controller

  App.addInitializer ->
    new DashboardeQISApp.Router
      controller: API

  App.vent.on "dashboardeqis:responsecount:clicked", (bucket) ->
    App.navigate "history/group/#{bucket}", trigger: true

