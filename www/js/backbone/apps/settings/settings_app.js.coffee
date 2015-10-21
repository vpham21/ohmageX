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

    goToGoals: ->
      App.navigate "#goals", trigger: true

    goToProfile: ->
      App.navigate "#profile", trigger: true
      
    goToSettingsDate: ->
      App.navigate "#settings_date", trigger: true

  App.addInitializer ->
    new SettingsApp.Router
      controller: API

  App.vent.on "settings:navigate:goals", ->
    console.log 'settings_app.settings:navigate:goals'
    API.goToGoals()

  App.vent.on "settings:navigate:profile", ->
    console.log 'settings_app.settings:navigate:profile'
    API.goToProfile()  

  App.vent.on "settings:navigate:settings_date", ->
    console.log 'settings_date_app.settings:navigate:settings_date'
    API.goToSettingsDate()