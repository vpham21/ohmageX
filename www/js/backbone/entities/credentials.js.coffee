@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials Entity provides an interface for login credentials.


  class Entities.Credentials extends Entities.Model

  currentCredentials = new Entities.Credentials

  API =
    getCredentials: ->
      currentCredentials

    isParsedAuthValid: (response) ->
      response.result isnt "failure"

    validateCredentials: (username, password) ->

      $.ajax
        type: "POST"
        url: 'https://test.ohmage.org/app/user/auth'
        data:
          user: username
          password: password
          client: 'ohmage-ios'
        dataType: 'json'
        success: (response) =>
          if @isParsedAuthValid response
            currentCredentials.set 'username', username
            currentCredentials.set 'password', response.hashed_password
            App.vent.trigger "credentials:validated", username
          else
            App.vent.trigger "credentials:invalidated", response.errors


  App.reqres.setHandler "credentials:current", ->
    API.getCredentials()

  App.commands.setHandler "credentials:validate", (username, password) ->
    API.validateCredentials username, password
