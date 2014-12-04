@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the progress indicators 
  # for a given step in the flow.

  class Entities.FlowProgress extends Entities.Model

  API =
    getProgress: (currentFlow, currentStep) ->
      # subtract 1 from duration, 0th array indexing
      new Entities.FlowProgress
        duration: currentFlow.length - 1
        position: currentFlow.indexOf(currentStep)

  App.reqres.setHandler "flow:progress", (stepId) ->
    currentFlow = App.request "flow:current"
    currentStep = App.request "flow:step", stepId
    API.getProgress currentFlow, currentStep
