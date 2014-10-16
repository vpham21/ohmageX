@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey tracker Entity tracks whether
  # the user is currently engaged in a survey or not.

  currentStatus = false

  API =
    setActive: ->
      currentStatus = true
    setInactive: ->
      currentStatus = false

  App.reqres.setHandler "surveytracker:active", ->
    currentStatus

  App.vent.on "survey:start", (surveyId) ->
    API.setActive()

  App.vent.on "survey:exit", (surveyId) ->
    API.setInactive()
