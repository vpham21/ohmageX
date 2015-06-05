@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Global app state entity.
  # Allow other modules to know the current global state of the app.
  # Only applies to app states that are global and not tied to another
  # Entity (so this excludes cases like the logged in state and whether
  # a survey is active)

  API =

    getLoadingSpinnerActive: ->
      "#{$('body').attr('loading-spinner-state')}" is "active"

    getHamburgermenuActive: ->
      "#{$('body').attr('slideout-state')}" is "active"

  App.reqres.setHandler "appstate:loading:active", ->
    API.getLoadingSpinnerActive()

  App.reqres.setHandler "appstate:hamburgermenu:active", ->
    API.getHamburgermenuActive()
