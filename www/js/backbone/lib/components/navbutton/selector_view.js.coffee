@Ohmage.module "Components.Navbutton", (Navbutton, App, Backbone, Marionette, $, _) ->

  class Navbutton.Sync extends App.Views.ItemView
    template: "navbutton/sync"
    tagName: "button"
    initialize: ->
      # TODO: Add handlers for disabling the button
      # when sync is happening
      @listenTo @, "button:clicked", ->
        @trigger "button:sync"

    triggers:
      "click": "button:clicked"
