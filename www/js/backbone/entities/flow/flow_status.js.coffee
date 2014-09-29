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

  API =
    updateStatus: (currentStep, status) ->
      currentStep.set 'status', status
      console.log 'myStep', currentStep.toJSON()

  App.commands.setHandler "flow:status:update", (id, status) ->
    currentStep = App.request "flow:step", id
    API.updateStatus currentStep, status