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

    checkFutureReference: (flow, condition) ->
      stepIds = flow.pluck 'id'
      result = _.find stepIds, (stepId, index) =>
        if condition.indexOf(stepId) isnt -1
          # the condition contains a reference to a stepId.
          myStep = flow.at(index)
          # the step referenced is either currently displaying or pending,
          # meaning it's a future reference.
          if myStep.get('status') is 'displaying' or myStep.get('status') is 'pending' then return true

  App.reqres.setHandler "flow:condition:check", (id) ->
    currentFlow = App.request "flow:current"
    API.checkCondition currentFlow, id

  App.reqres.setHandler "flow:condition:invalid:future:reference", (condition) ->
    currentFlow = App.request "flow:current"
    API.checkFutureReference currentFlow, condition
