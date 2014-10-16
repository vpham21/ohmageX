@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials Entity provides an interface for login credentials.


  class Entities.Credentials extends Entities.Model

  currentCredentials = false

  API =
    init: ->
      App.request "storage:get", 'credentials', ((result) =>
        # credentials is retrieved from raw JSON.
        console.log 'credentials retrieved from storage'
        currentCredentials = new Entities.Credentials result
      ), =>
        console.log 'credentials not retrieved from storage'
        currentCredentials = false

    isParsedAuthValid: (response) ->
      response.result isnt "failure"

    getCredentials: ->
      if currentCredentials and currentCredentials.has('username')
        currentCredentials
      else
        false

    validateCredentials: (path, username, password) ->

      $.ajax
        type: "POST"
        url: "#{path}/app/user/auth"
        data:
          user: username
          password: password
          client: 'ohmage-mwf-dw-browser'
        dataType: 'json'
        success: (response) =>
          if @isParsedAuthValid response
            currentCredentials = new Entities.Credentials
              username: username
              password: response.hashed_password
            App.execute "storage:save", 'credentials', currentCredentials.toJSON(), =>
              console.log "credentials entity API.validateCredentials success"
              App.vent.trigger "credentials:validated", username
          else
            App.vent.trigger "credentials:invalidated", response.errors
    logout: ->
      currentCredentials = false

      App.execute "storage:clear", 'credentials', ->
        console.log 'credentials erased'
        App.vent.trigger "credentials:cleared"

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "credentials:current", ->
    API.getCredentials()

  App.commands.setHandler "credentials:validate", (username, password) ->
    API.validateCredentials App.request("serverpath:current"), username, password

  App.commands.setHandler "credentials:logout", ->
    API.logout()
