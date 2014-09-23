@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the ID handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    firstId: (currentFlow) ->
      # Limit our starting search to the first two items, no need to search all.
      # Then remove any with a "false" condition.
      # Then only return the first model that we get back from our condition check.
      # Then return its id.
      result = currentFlow.find((step) ->
        step.get('condition') isnt false
      )
      throw new Error "All Flow step conditions are false" if typeof result is 'undefined'
      result.get 'id'


  App.reqres.setHandler "flow:id:first", ->
    currentFlow = App.request "flow:current"
    API.firstId currentFlow
