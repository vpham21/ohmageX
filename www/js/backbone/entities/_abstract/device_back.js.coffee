@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # general handler for device back button. Used for any device
  # that includes a hardware back button (not a browser back button)

  backOverwrite = false

  API =
    init: ->
      document.addEventListener 'backbutton', (=>
        console.log 'device back button activated'

        if !backOverwrite and 
          !App.request("surveytracker:active") and 
          !App.request("appstate:hamburgermenu:active") and 
          !App.request("appstate:loading:active")
            # Event hasn't been overwritten,
            # there is no current survey active,
            # the hamburger menu is not open,
            # and the loader / blocker isn't showing.
            # By default, just go back
            App.historyBack()
        else
          App.vent.trigger "device:back:button"

      ), false

      App.vent.on 'device:dialog:alert:show device:dialog:confirm:show', ->
        API.enableOverwrite()

      App.vent.on 'device:dialog:alert:close device:dialog:confirm:close', ->
        API.disableOverwrite()

      App.vent.on 'device:back:button', ->
        App.vent.trigger 'external:blocker:cancel'
        App.vent.trigger 'external:survey:prev:navigate'
        App.vent.trigger 'external:hamburgermenu:close'

    enableOverwrite: ->
      console.log 'overwrite enabled'
      backOverwrite = true

    disableOverwrite: ->
      console.log 'overwrite disabled'
      backOverwrite = false

  App.on "before:start", ->
    if App.device.isNative
      API.init()
