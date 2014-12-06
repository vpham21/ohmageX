@Ohmage.module "Components.Navbutton", (Navbutton, App, Backbone, Marionette, $, _) ->

  class Navbutton.Sync extends App.Views.ItemView
    template: "navbutton/sync"
    tagName: "button"
    className: "sync icon"
    initialize: ->
      # TODO: Add handlers for disabling the button
      # when sync is happening
      @listenTo @, "button:clicked", ->
        @trigger "button:sync"

    triggers:
      "click": "button:clicked"

  class Navbutton.Upload extends App.Views.ItemView
    template: "navbutton/upload"
    tagName: "button"
    className: "sync icon"
    initialize: ->
      # TODO: Add handlers for disabling the button
      # when sync is happening
      @listenTo @, "button:clicked", ->
        @trigger "button:upload"

    triggers:
      "click": "button:clicked"
