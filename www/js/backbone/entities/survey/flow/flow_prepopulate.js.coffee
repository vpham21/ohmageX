@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The flow Prepopulate Entity prepopulates the flow with given
  # values by stepId.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  currentEntries = false

  class Entities.PrepopulateEntry extends Backbone.Model

  class Entities.PrepopulateEntries extends Backbone.Collection
    model: Entities.PrepopulateEntry

  API =
    clear: ->
      currentEntries = false
    addPrepopulateEntry: (stepId, value) ->
      if currentEntries is false then currentEntries = new Entities.PrepopulateEntries

      currentEntries.add
        id: stepId
        value: value

  App.vent.on "survey:exit survey:reset", ->
    API.clear()

  App.commands.setHandler "flow:prepop:add", (stepId, value) ->
    API.addPrepopulateEntry stepId, value
