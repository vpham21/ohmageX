@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # the credentials preflight entity handles all pre-flight credentials
  # checks.

  API =
    isParsedAuthValid: (response) ->
      response.result isnt "failure"

    showBlocker: (callback) ->
      App.vent.trigger 'blocker:password:invalid',
        successListener: callback
  App.vent.on "surveys:saved:campaign:fetch:failure:auth campaigns:sync:failure:auth", (errorText) ->
    API.showBlocker (->
      App.execute "dialog:alert", "Password validated."
    )

  App.vent.on "uploadqueue:upload:failure:auth", (responseData, errorText, surveyId) ->
    API.showBlocker (->
      App.execute "dialog:alert", "Password validated."
    )
