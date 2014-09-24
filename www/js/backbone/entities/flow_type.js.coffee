@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Type handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    getType: (currentStep) ->
      currentStep.get 'type'

  App.reqres.setHandler "flow:type", (id) ->
    currentStep = App.request "flow:step", id
    API.getType currentStep