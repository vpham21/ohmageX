@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The credentials token Entity provides an interface for login via token.

  currentAuthToken = false

  API =
    tokenVerify: ->
      # use whoami to get the username and save it.
      currentAuthToken = myGetCookie('auth_token')

      if currentAuthToken is null
        @tokenLoginRedirect()
        return false
    tokenLoginRedirect: ->
      # redirect to server login page.
      window.location.replace '/web/#login'

    saveTokenCredentials: (username) ->
      App.credentials = new Entities.Credentials
        username: username
        auth_token: currentAuthToken
      App.vent.trigger "credentials:storage:load:success"
      App.execute "storage:save", 'credentials', App.credentials.toJSON(), =>
        console.log "credentials token new credentials saved"

  App.commands.setHandler "credentials:token:verify", ->
    API.tokenVerify()
  App.commands.setHandler "credentials:token:redirect", ->
    API.tokenLoginRedirect()

