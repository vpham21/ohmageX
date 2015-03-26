@Ohmage.module "LogoutApp", (LogoutApp, App, Backbone, Marionette, $, _) ->

  class LogoutApp.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "logout": "logout"

  API =
    logout: ->
      console.log "login:logout:selected"
      App.execute "credentials:logout"

  App.addInitializer ->
    new LogoutApp.Router
      controller: API
