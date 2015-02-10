@Ohmage.module "LoginApp", (LoginApp, App, Backbone, Marionette, $, _) ->

  class LoginApp.Router extends Marionette.AppRouter
    before: ->
      if App.request("credentials:isloggedin")
        App.navigate Routes.dashboard_route(), trigger: true
        return false
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
