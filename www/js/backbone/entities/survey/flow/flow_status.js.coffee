@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Status handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  # Possible status list:
  # pending        - Not yet navigated to, and its Condition is not yet tested
  # displaying     - currently rendered, no response from the user yet
  # not_displayed  - not displayed because its condition evaluated to false
  # complete       - has been displayed, and the user has submitted a valid value
  # skipped        - the user intentionally skipped this Step
  # skipped_displaying - both skipped AND displaying, required for multi-step flow

  API =
    updateStatus: (currentStep, status) ->
      currentStep.set 'status', status

    getStatus: (currentStep) ->
      currentStep.get 'status'

    setSkippedDisplayingToSkipped: (flow) ->
      flowSkippedDisplaying = flow.where(status: 'skipped_displaying')
      _.each(flowSkippedDisplaying, (step) -> step.set 'status', 'skipped')

  App.reqres.setHandler "flow:status", (id) ->
    currentStep = App.request "flow:step", id
    API.getStatus currentStep

  App.commands.setHandler "flow:status:update", (id, status) ->
    currentStep = App.request "flow:step", id
    API.updateStatus currentStep, status

  App.vent.on "survey:step:goback", (surveyId, stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "pending"

  App.vent.on "flow:step:reset", (stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "pending"

  App.vent.on "survey:step:skipped", (stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "skipped"

  App.vent.on "survey:step:skipped_displaying", (stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "skipped_displaying"

  App.vent.on "survey:step:unskipped", (stepId) ->
    # this event is assumed to only happen during multi-step flow.
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "displaying"

  App.vent.on "response:set:success", (response, surveyId, stepId) ->
    console.log 'response:set:success'
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "complete"

  App.vent.on "flow:condition:failed", (stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "not_displayed"

  App.vent.on "flow:condition:success", (stepId) ->
    currentStep = App.request "flow:step", stepId
    API.updateStatus currentStep, "displaying"

  App.vent.on "survey:page:responses:success", (surveyId) ->
    currentFlow = App.request "flow:current"
    API.setSkippedDisplayingToSkipped currentFlow
