@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials Entity provides an interface for login credentials.


  class Entities.Credentials extends Entities.Model

  currentCredentials = new Entities.Credentials

  API =
    getCredentials: ->
      currentCredentials
    setCredentials: (username, password) ->

      $.ajax
        type: "POST"
        url: 'https://test.ohmage.org/app/user/auth'
        data:
          user: username
          password: password
          client: 'ohmage-ios'
        dataType: 'json'
        success: (response) =>
          currentCredentials.set 'username', username
          currentCredentials.set 'password', response.hashed_password

  App.reqres.setHandler "credentials:current", ->
    API.getCredentials()

  App.commands.setHandler "credentials:set", (username, password) ->
    API.setCredentials username, password
