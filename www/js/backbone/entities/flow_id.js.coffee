@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the ID handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    firstId: (currentFlow) ->
      # Only return the first model that we receive from the condition check.
      # Then return its id.
      result = currentFlow.find((step) ->
        step.get('condition') isnt false
      )
      throw new Error "All Flow step conditions are false" if typeof result is 'undefined'
      result.get 'id'
    currentIndex: (currentFlow, id) ->

      currentStep = currentFlow.get id
      myIndex = currentFlow.indexOf currentStep
      throw new Error "id #{id} is not in currentFlow" if myIndex is -1
      myIndex

    nextId: (currentFlow, id) ->
      myIndex = @currentIndex currentFlow, id

      result = currentFlow.at(myIndex+1)
      throw new Error "id #{id} in currentFlow has no next id" if typeof result is 'undefined'
      result.get 'id'
  App.reqres.setHandler "flow:id:first", ->
    currentFlow = App.request "flow:current"
    API.firstId currentFlow

  App.reqres.setHandler "flow:id:next", (id) ->
    currentFlow = App.request "flow:current"
    API.nextId currentFlow, id
