@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # the credentials preflight entity handles all pre-flight credentials
  # checks.

  API =
    isParsedAuthValid: (response) ->
      response.result isnt "failure"

    preflightCheck: (path, callback) ->
      App.vent.trigger "loading:show", "Loading..."

      myData =
        client: App.client_string

      $.ajax
        type: "POST"
        url: "#{path}/app/user_info/read"
        data: _.extend(myData, App.request("credentials:upload:params"))
        dataType: 'json'
        success: (response) =>
          App.vent.trigger "loading:hide"
          if @isParsedAuthValid response
            callback()
          else
            @showBlocker callback

        error: =>
          App.vent.trigger "loading:hide"
          # network error of some kind. Try the result and
          # let its error handlers deal with the network issue.
          callback()

    showBlocker: (callback) ->
      App.vent.trigger 'blocker:password:invalid',
        successListener: callback

  App.commands.setHandler 'credentials:preflight:check', (callback) ->
    if App.request "credentials:ispassword"
      API.preflightCheck App.request("serverpath:current"), callback
    else
      # just execute the callback if using tokens. An auth failure will trigger
      # a token redirect instead.
      callback()

  App.vent.on "surveys:saved:campaign:fetch:failure:auth campaigns:sync:failure:auth", (errorText) ->
    API.showBlocker (->
      App.execute "dialog:alert", "Password validated."
    )

  App.vent.on "uploadqueue:upload:failure:auth", (responseData, errorText, surveyId) ->
    API.showBlocker (->
      App.execute "dialog:alert", "Password validated."
    )
