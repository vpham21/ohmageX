@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # general handler for device back button. Used for any device
  # that includes a hardware back button (not a browser back button)

  backOverwrite = false

  API =
    init: ->
      document.addEventListener 'backbutton', (=>
        console.log 'device back button activated'
        App.vent.trigger "android:back:button"
      ), false

      App.vent.on 'device:dialog:alert:show device:dialog:confirm:show', ->
        API.enableOverwrite()

      App.vent.on 'device:dialog:alert:close device:dialog:confirm:close', ->
        API.disableOverwrite()
    enableOverwrite: ->
      console.log 'overwrite enabled'
      backOverwrite = true

    disableOverwrite: ->
      console.log 'overwrite disabled'
      backOverwrite = false

  App.on "before:start", ->
    if App.device.isNative
      API.init()
