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
        App.vent.trigger "flow:condition:success", stepId
        return true
      else
        # condition fails
        App.vent.trigger "flow:condition:failed", stepId
        return false

    parseCondition: (rawCondition, currentResponses) ->
      # rawCondition: Condition string from XML, to be parsed
      # currentResponses: ResponseCollection

      if rawCondition is true or rawCondition is false then return rawCondition

      # use all responses to evaluate the values of the step's Condition
      result = App.request "oldcondition:evaluate", rawCondition, currentResponses
      console.log "oldcondition:evaluate", result
      result

  App.reqres.setHandler "flow:condition:check", (id) ->
    currentFlow = App.request "flow:current"
    API.checkCondition currentFlow, id