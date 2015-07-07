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

    containsInvalidFutureReference: (flow, condition) ->
      console.log 'containsInvalidFutureReference'
      stepIds = flow.pluck 'id'
      if typeof condition is "string"
        # only check string-based conditions, boolean conditions won't contain any references
        result = _.find stepIds, (stepId, index) =>
          if condition.indexOf(stepId) is -1
            return false
          else
            # the condition contains a reference to a stepId.
            myStep = flow.at(index)

            # the step referenced is either currently displaying or pending,
            # meaning it's a future reference.
            return myStep.get('status') in ['pending','displaying','skipped_displaying']
        # if there were matches, that means there's a future reference in the condition
        return typeof result isnt "undefined"
      else
        return false

  App.reqres.setHandler "flow:condition:check", (id) ->
    currentFlow = App.request "flow:current"
    API.checkCondition currentFlow, id

  App.reqres.setHandler "flow:condition:invalid:future:reference", (condition) ->
    currentFlow = App.request "flow:current"
    API.containsInvalidFutureReference currentFlow, condition
