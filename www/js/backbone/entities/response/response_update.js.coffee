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

  App.commands.setHandler "response:set:not_displayed", (stepId) ->
    currentResponses = App.request "responses:current"
    API.updateResponse currentResponses, stepId, 'NOT_DISPLAYED'