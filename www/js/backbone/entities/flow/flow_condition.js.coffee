@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Condition handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    checkCondition: (currentFlow, stepId) ->
      result = currentFlow.findWhere({id: stepId })
      throw new Error "Flow id #{stepId} does not exist in currentFlow" if typeof result is 'undefined'
      myRawCondition = result.get 'condition'

      if @parseCondition(myRawCondition, App.request "responses:current")
        App.execute "flow:status:update", stepId, "displaying"
        return true
      else
        # condition fails
        App.execute "flow:status:update", stepId, "not_displayed"
        App.execute "response:set:not_displayed", stepId
        return false

    parseCondition: (rawCondition, currentResponses) ->
      # rawCondition: Condition string from XML, to be parsed
      # currentResponses: ResponseCollection

      # TODO: Implement condition parser

      # use all responses to evaluate the values of the step's Condition

      # pass through the condition until implemented
      true

  App.reqres.setHandler "flow:condition:check", (id) ->
    currentFlow = App.request "flow:current"
    API.checkCondition currentFlow, id