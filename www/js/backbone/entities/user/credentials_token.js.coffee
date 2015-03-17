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
          if @isParsedAuthValid response
            @compareSavedUsername response.username
          else
            @tokenLoginRedirect()
        error: =>
          @tokenLoginRedirect()

    tokenLoginRedirect: ->
      # redirect to server login page.
      App.vent.trigger "loading:show", "Authentication failed, redirecting to login page..."
      setTimeout (=>
        window.location.replace App.custom.api.token_redirect
      ), 1500

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
      # must navigate directly to the dashboard route here, because
      # when credentials are loaded from storage for comparison,
      # the App `credentials` property is set later here, and this takes place AFTER
      # the default page renders and its Router `before:` handler fires.
      App.navigate Routes.dashboard_route(), trigger: true
      App.vent.trigger "credentials:storage:load:success"
      App.execute "storage:save", 'credentials', App.credentials.toJSON(), =>
        console.log "credentials token new credentials saved"

    getTokenParam: ->
      auth_token: currentAuthToken

    isParsedAuthValid: (response) ->
      response.result isnt "failure"

  App.commands.setHandler "credentials:token:verify", ->
    API.tokenVerify()

  App.reqres.setHandler "credentials:token:param", ->
    API.getTokenParam()

  App.vent.on "uploadqueue:upload:failure:auth", (responseData, errorText, surveyId) ->
    if !App.request("credentials:ispassword")
      API.tokenLoginRedirect()

  App.vent.on "survey:upload:failure:auth", (responseData, errorText, surveyId) ->
    if !App.request("credentials:ispassword")
      # OK to set a global handler here, a redirect will happen and reset the app.
      App.vent.on 'uploadqueue:add:success', =>
        # after the queue item has been saved, redirect to the actual upload queue,
        # so if they come back it will be on this page.
        App.execute 'survey:reset'
        App.navigate "uploadqueue", {trigger: true}
        API.tokenLoginRedirect()

  App.vent.on "surveys:saved:campaign:fetch:failure:auth campaigns:sync:failure:auth", (errorText) ->
    if !App.request("credentials:ispassword")
      API.tokenLoginRedirect()

  App.vent.on "credentials:cleared", ->
    if !App.request("credentials:ispassword")
      # Go back to the token login page if credentials:cleared
      # is somehow triggered in the browser.
      setTimeout (=>
        window.location.replace App.custom.api.token_redirect
      ), 1500
