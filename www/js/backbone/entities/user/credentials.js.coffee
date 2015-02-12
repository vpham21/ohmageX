@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials Entity provides an interface for login credentials.


  class Entities.Credentials extends Entities.Model

  API =
    init: ->
      App.request "storage:get", 'credentials', ((result) =>
        # credentials is retrieved from raw JSON.
        console.log 'credentials retrieved from storage'
        App.credentials = new Entities.Credentials result
        App.vent.trigger "credentials:storage:load:success"
      ), =>
        console.log 'credentials not retrieved from storage'
        App.credentials = false
        App.vent.trigger "credentials:storage:load:failure"

    isParsedAuthValid: (response) ->
      response.result isnt "failure"

    getCredentials: ->
      if App.credentials isnt false and App.credentials.has('username') then App.credentials else false

    isPasswordAuth: ->
      App.custom.build.debug or App.device.isNative

    validateCredentials: (path, username, password) ->
      App.vent.trigger "loading:show", "logging in as #{username}..."
      $.ajax
        type: "POST"
        url: "#{path}/app/user/auth"
        data:
          user: username
          password: password
          client: App.client_string
        dataType: 'json'
        success: (response) =>
          if @isParsedAuthValid response
            # we don't hide the loading spinner on success, because when a user
            # logs in, their campaigns are fetched immediately and asynchronously.
            # Hiding it here would hide the loading spinner before the campaigns are
            # finished fetching.

            App.credentials = new Entities.Credentials
              username: username
              password: response.hashed_password
            App.execute "storage:save", 'credentials', App.credentials.toJSON(), =>
              console.log "credentials entity API.validateCredentials success"
              App.vent.trigger "credentials:validated", username
          else
            App.vent.trigger "loading:hide"
            App.vent.trigger "credentials:invalidated", response.errors
        error: ->
          App.vent.trigger "loading:hide"


    getParams: ->
      # currently using hashed password auth.
      # this will change when using other auth methods.
      if @getCredentials()
        return {
          user: App.credentials.get('username')
          password: App.credentials.get('password')
        }
      else return false
    logout: ->
      App.credentials = false

      App.vent.trigger "credentials:cleared"
      App.execute "storage:clear", 'credentials', ->
        console.log 'credentials erased'

  App.on "before:start", ->
    API.init()

  App.reqres.setHandler "credentials:isloggedin", ->
    !!API.getCredentials()

  App.reqres.setHandler "credentials:current", ->
    API.getCredentials()

  App.reqres.setHandler "credentials:username", ->
    credentials = API.getCredentials()
    if !credentials then return false
    credentials.get 'username'

  App.reqres.setHandler "credentials:upload:params", ->
    API.getParams()

  App.commands.setHandler "credentials:validate", (username, password) ->
    API.validateCredentials App.request("serverpath:current"), username, password

  App.commands.setHandler "credentials:logout", ->
    API.logout()
