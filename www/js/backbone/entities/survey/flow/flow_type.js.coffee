@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Type handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  # custom Step Types (not types within Prompts), no Response added:
  # intro - Introductory step, shown before the Survey
  # beforeSurveySubmit - Going Next on this step submits the Survey.
  # afterSurveySubmit - The Survey completion page.

  API =
    getType: (currentStep) ->
      currentStep.get 'type'
    isPromptType: (currentStep) ->
      result = switch @getType(currentStep)
        when "intro","message","beforeSurveySubmit","afterSurveySubmit" then false
        else true

  App.reqres.setHandler "flow:type", (id) ->
    currentStep = App.request "flow:step", id
    API.getType currentStep

  App.reqres.setHandler "flow:type:is:prompt", (id) ->
    currentStep = App.request "flow:step", id
    API.isPromptType currentStep
