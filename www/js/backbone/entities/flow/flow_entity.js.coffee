@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Entity handlers for Flow.
  # This is a reference to fetching individual Prompt Entities
  # for a flow, based on its type.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    getEntity: (currentStep) ->
      myType = currentStep.get 'type'
      $myXML = currentStep.get '$XML'
      # Only set our entity if it hasn't been initialized yet.
      # This way the entity's individual XML is rapidly parsed only when needed.
      if currentStep.get('entity') is false then currentStep.set( 'entity', App.request "prompt:entity", myType, $myXML )
      currentStep.get 'entity'

  App.reqres.setHandler "flow:entity", (id) ->
    currentStep = App.request "flow:step", id
    API.getEntity currentStep