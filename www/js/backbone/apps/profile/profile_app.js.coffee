@Ohmage.module "ProfileApp", (ProfileApp, App, Backbone, Marionette, $, _) ->

  class ProfileApp.Router extends Marionette.AppRouter
    before: ->
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        if confirm('do you want to exit the survey?')
          # reset the survey's entities.
          App.vent.trigger "survey:reset"
        else
          # They don't want to exit the survey, cancel.
          # Move the history to its previous URL.
          App.historyPrevious()
          return false
    appRoutes:
      "profile": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "Profile"
      console.log 'ProfileApp show'
      new ProfileApp.Show.Controller

  App.addInitializer ->
    new ProfileApp.Router
      controller: API
