@Ohmage.module "LoginApp", (LoginApp, App, Backbone, Marionette, $, _) ->

  class LoginApp.Router extends Marionette.AppRouter
    before: ->
      if App.request("credentials:isloggedin")
        App.navigate Routes.dashboard_route(), trigger: true
        return false
    appRoutes:
      "login": "show"

  API =
    show: (id) ->
      App.vent.trigger "nav:choose", "login"
      console.log 'loginApp show'
      new LoginApp.Show.Controller

  App.addInitializer ->
    new LoginApp.Router
      controller: API

  App.vent.on "login:form:submit:clicked", (formValues) ->
    App.execute "credentials:validate", formValues.username, formValues.password

  App.vent.on "credentials:validated", (username) ->
    App.navigate Routes.dashboard_route(), { trigger: true }

  App.vent.on "credentials:cleared", ->
    App.navigate Routes.default_route(), { trigger: true }
