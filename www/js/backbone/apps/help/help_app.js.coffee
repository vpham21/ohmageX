@Ohmage.module "HelpApp", (HelpApp, App, Backbone, Marionette, $, _) ->

  class HelpApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "help": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "help"
      console.log 'HelpApp show'
      new HelpApp.Show.Controller

  App.addInitializer ->
    new HelpApp.Router
      controller: API
