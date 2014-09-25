@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.
  # This module contains the handlers that validate a response,
  # based on its flow Entity.

  # currentResponses
  # References the current Response ResponseCollection object, defined in response.js.coffee
  # via the interface "responses:current"

  API =
    validateResponse: (options) ->
      { response, entity, type, surveyId, stepId } = options

      # false if the response is empty
      if !!!response
        App.vent.trigger "response:set:error", "Please enter a response."
        return false

      # TODO: Add validations for each prompt type.
      # use the entity to define properties and values
      # for the submitted response, based on type.

      # response is correct and valid
      App.execute "response:set", response, stepId
      App.vent.trigger "response:set:success", response, surveyId, stepId

  App.commands.setHandler "response:validate", (response, surveyId, stepId) ->
    API.validateResponse
      response: response
      entity: App.request "flow:entity", stepId
      type: App.request "flow:type", stepId
      surveyId: surveyId
      stepId: stepId
