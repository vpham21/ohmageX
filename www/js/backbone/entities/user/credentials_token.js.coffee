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

      $.ajax
        type: "POST"
        url: "/app/user/whoami"
        data:
          client: App.client_string
          auth_token: currentAuthToken
        dataType: 'json'
        success: (response) =>
          if @isParsedAuthValid()
            @compareSavedUsername response.username
          else
            @tokenLoginRedirect()
        error: =>
          @tokenLoginRedirect()

    tokenLoginRedirect: ->
      # redirect to server login page.
      window.location.replace '/web/#login'

    compareSavedUsername: (username) ->
      App.request "storage:get", 'credentials', ((result) =>
        # credentials is retrieved from raw JSON.
        console.log 'credentials retrieved from storage for comparison'
        if result.username is username
          # save credentials to app and storage
          @saveTokenCredentials username
        else
          # username and saved username don't match
          # log the current user out
          App.execute "credentials:logout"
          # let them log in again
          @tokenLoginRedirect()
      ), =>
        console.log 'credentials not retrieved from storage for comparison'
        # save credentials to app and storage
        @saveTokenCredentials username

    saveTokenCredentials: (username) ->
      App.credentials = new Entities.Credentials
        username: username
        auth_token: currentAuthToken
      App.vent.trigger "credentials:storage:load:success"
      App.execute "storage:save", 'credentials', App.credentials.toJSON(), =>
        console.log "credentials token new credentials saved"

    isParsedAuthValid: (response) ->
      response.result isnt "failure"

  App.commands.setHandler "credentials:token:verify", ->
    API.tokenVerify()
  App.commands.setHandler "credentials:token:redirect", ->
    API.tokenLoginRedirect()

