@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.
  # This module contains the handlers that update a response.

  # currentResponses
  # References the current Response ResponseCollection object, defined in response.js.coffee
  # via the interface "responses:current"

  API = 
    updateResponse: (options) ->
      { myResponse, newValue, validate } = options
      console.log 'myResponse set validate', validate
      myResponse.set {response: newValue }, { validate: validate }
      console.log 'myResponse', myResponse.toJSON()

  App.vent.on "flow:condition:failed survey:step:skipped", (stepId) ->
    # all invalid responses are flagged as "false",
    # and are processed into the equivalents required
    # by the server before upload, based on their flow status.
    API.updateResponse
      myResponse: App.request "response:get", stepId
      newValue: false
      validate: false

  App.commands.setHandler "response:set", (newValue, stepId) ->
    API.updateResponse
      myResponse: App.request "response:get", stepId
      newValue: newValue
      validate: true
