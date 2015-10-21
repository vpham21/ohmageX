@Ohmage.module "GoalsApp", (GoalsApp, App, Backbone, Marionette, $, _) ->

  class GoalsApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "goals": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "goals"
      console.log 'GoalsApp show'
      new GoalsApp.Show.Controller
    
    saveGoals: (goals) ->
      App.vent.trigger "user:preferences:goals:set", goals
        
  App.addInitializer ->
    new GoalsApp.Router
      controller: API

  App.vent.on "goals:save:clicked", (goals) ->
    console.log 'goals.settings_date:save:clicked'
    API.saveGoals(goals)
