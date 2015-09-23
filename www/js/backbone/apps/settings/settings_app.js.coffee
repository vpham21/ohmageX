@Ohmage.module "SettingsApp", (SettingsApp, App, Backbone, Marionette, $, _) ->

  class SettingsApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "settings": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "settings"
      console.log 'SettingsApp show'
      new SettingsApp.Show.Controller

  App.addInitializer ->
    new SettingsApp.Router
      controller: API
