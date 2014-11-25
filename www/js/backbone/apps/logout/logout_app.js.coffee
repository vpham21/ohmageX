@Ohmage.module "LogoutApp", (LogoutApp, App, Backbone, Marionette, $, _) ->

  class LogoutApp.Router extends Marionette.AppRouter
    before: ->
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        if confirm('do you want to logout and exit the survey?')
          # Don't reset the survey entities yet,
          # it's needed to avoid the second confirmation box.
        else
          # They don't want to exit the survey, cancel.
          # Move the history to its previous URL.
          App.historyPrevious()
          return false
    appRoutes:
      "logout": "logout"

  API =
    logout: ->
      console.log "login:logout:selected"
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        # reset the survey's entities.
        App.vent.trigger "survey:reset"
        App.execute "credentials:logout"
      else if confirm 'Do you want to logout?'
        App.execute "credentials:logout"

  App.addInitializer ->
    new LogoutApp.Router
      controller: API
