@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # general handler for device back button. Used for any device
  # that includes a hardware back button (not a browser back button)

  API =
    init: ->
      document.addEventListener 'backbutton', (=>
        console.log 'device back button activated'
        App.vent.trigger "android:back:button"
      ), false

  App.on "before:start", ->
    if App.device.isNative
      API.init()
