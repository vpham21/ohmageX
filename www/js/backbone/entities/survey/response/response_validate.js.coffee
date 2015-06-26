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
        message = switch type
          when "single_choice", "single_choice_custom", "multi_choice", "multi_choice_custom" then "Please select an option."
          when "photo" then "Please take an image to submit."
          when "document" then "Please select a document."
          else "Please enter a response."
        App.vent.trigger "response:set:error", message, surveyId, stepId
        return false

      if response is App.request('response:get', stepId).get('response')
        # the response is identical, skip validation
        App.vent.trigger "response:set:success", response, surveyId, stepId
      else
        # set the response, allowing its model validate methods to verify the response
        App.execute "response:set", response, stepId

  App.commands.setHandler "response:validate", (response, surveyId, stepId) ->
    API.validateResponse
      response: response
      entity: App.request "flow:entity", stepId
      type: App.request "flow:type", stepId
      surveyId: surveyId
      stepId: stepId
