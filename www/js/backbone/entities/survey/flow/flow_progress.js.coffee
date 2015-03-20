@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the progress indicators 
  # for a given step in the flow.

  class Entities.FlowProgress extends Entities.Model

  API =
    getProgress: (currentFlow, currentStep) ->
      # also makes the first step count as "zero"
      myPosition = currentFlow.indexOf(currentStep) - 1

      # If an intro step was displayed, it would result in a negative myPosition.
      # set it to zero to prevent an invalid progress amount.
      if myPosition < 0 then myPosition = 0

      # removes introStep, beforeSubmit, and afterSubmit from progress count.
      myDuration = currentFlow.length - 3

      new Entities.FlowProgress
        duration: myDuration
        position: if myPosition > myDuration then myDuration else myPosition

  App.reqres.setHandler "flow:progress", (stepId) ->
    currentFlow = App.request "flow:current"
    currentStep = App.request "flow:step", stepId
    API.getProgress currentFlow, currentStep
