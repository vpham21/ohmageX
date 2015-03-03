@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # the credentials preflight entity handles all pre-flight credentials
  # checks.

  API =
    isParsedAuthValid: (response) ->
      response.result isnt "failure"

