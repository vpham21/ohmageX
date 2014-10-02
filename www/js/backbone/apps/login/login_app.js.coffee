@Ohmage.module "LoginApp", (LoginApp, App, Backbone, Marionette, $, _) ->

  class LoginApp.Router extends Marionette.AppRouter
    appRoutes:
      "login": "show"
    
  API =
    show: (id) ->
      console.log 'loginApp show'
      new LoginApp.Show.Controller

  App.addInitializer ->
    new LoginApp.Router
      controller: API

  App.vent.on "login:form:submit:clicked", (formValues) ->
    App.execute "credentials:validate", formValues.username, formValues.password

  App.vent.on "credentials:validated", (username) ->
    App.navigate Routes.dashboard_route(), { trigger: true }

