@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey tracker Entity tracks whether
  # the user is currently engaged in a survey or not.
  # it also tracks the currently viewed Page of the survey,
  # if using the multi-question view.

  currentStatus = false
  currentPage = false

  API =
    setActive: ->
      currentStatus = true
    setInactive: ->
      currentStatus = false
    startPages: ->
      currentPage = 1
    endPages: ->
      currentPage = false

  App.reqres.setHandler "surveytracker:active", ->
    currentStatus

  App.vent.on "survey:start", (surveyId) ->
    API.setActive()
    API.startPages()

  App.vent.on "survey:exit survey:reset", (surveyId) ->
    API.setInactive()
    API.endPages()
