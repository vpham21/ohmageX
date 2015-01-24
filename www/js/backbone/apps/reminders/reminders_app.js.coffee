@Ohmage.module "RemindersApp", (RemindersApp, App, Backbone, Marionette, $, _) ->

  class RemindersApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin") # or !App.device.isNative
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "reminders": "list"

  API =
    list: (options) ->
      App.vent.trigger "nav:choose", "Reminders"
      console.log 'RemindersApp list'
      new RemindersApp.List.Controller options

  App.addInitializer ->
    new RemindersApp.Router
      controller: API

  App.commands.setHandler "reminders:force:refresh", ->
    console.log 'force refresh'
    API.list
      forceRefresh: true
