@Ohmage.module "RemindersApp", (RemindersApp, App, Backbone, Marionette, $, _) ->

  class RemindersApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin") or !App.cordova
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "reminders": "list"

  API =
    list: ->
      App.vent.trigger "nav:choose", "Reminders"
      console.log 'RemindersApp list'
      new RemindersApp.List.Controller

  App.addInitializer ->
    new RemindersApp.Router
      controller: API
