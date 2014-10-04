@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.
  # This module contains the handlers that update a response.

  # currentResponses
  # References the current Response ResponseCollection object, defined in response.js.coffee
  # via the interface "responses:current"

  API = 
    updateResponse: (currentResponses, id, newResponse) ->
      myResponse = currentResponses.get(id)
      throw new Error "response id #{id} does not exist in currentResponses" if typeof myResponse is 'undefined'
      myResponse.set 'response', newResponse
      console.log 'myResponse', myResponse.toJSON()

  App.vent.on "flow:condition:failed survey:step:skipped", (stepId) ->
    currentResponses = App.request "responses:current"
    # all invalid responses are flagged as "false",
    # and are processed into the equivalents required
    # by the server before upload, based on their flow status.
    API.updateResponse currentResponses, stepId, false

  App.commands.setHandler "response:set", (newResponse, stepId) ->
    currentResponses = App.request "responses:current"
    API.updateResponse currentResponses, stepId, newResponse
