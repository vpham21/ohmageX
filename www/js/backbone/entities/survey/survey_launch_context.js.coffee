@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This tracks the survey launch context.

  currentContext = false

  API =
    setContext: ->
      currentContext =
        launch_time: moment().unix()
        launch_timezone: _.jstz()
        active_triggers: []
    removeContext: ->
      currentContext = false

  App.reqres.setHandler "survey:launchcontext", ->
    currentContext

  App.vent.on "survey:start", (surveyId) ->
    API.setContext()

  App.vent.on "survey:exit survey:reset", (surveyId) ->
    API.removeContext()
