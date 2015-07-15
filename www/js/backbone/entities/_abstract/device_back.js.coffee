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
          !App.request("uploadtracker:uploading") and 
          !App.request("appstate:hamburgermenu:active") and 
          !App.request("appstate:loading:active")
            # Event hasn't been overwritten,
            # there is no current survey active,
            # the hamburger menu is not open,
            # and the loader / blocker isn't showing.
            # Execute the default handler
            @defaultBackAction()
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

    defaultBackAction: ->
      console.log 'defaultBackAction'
      if App.navs.getSelectedName() is App.custom.build.homepage or App.navs.getSelectedName() is "login"
        # we're on the homepage or login screen
        console.log 'on the homepage or login screen'
        App.execute "dialog:confirm", "Exit the app?", (=>
          navigator.app.exitApp()
        )
      else if App.navs.getSelectedName() is "queue" and App.getCurrentRoute() isnt null and App.getCurrentRoute().indexOf('/') isnt -1
        # we're in an upload queue item, navigate back to the upload queue list
        console.log "we're in an upload queue item, navigate back to the upload queue list"
        App.navigate App.navs.getUrlByName('queue'), trigger: true
      else
        # just go to the homepage
        console.log 'go to homepage'
        App.navigate App.navs.getUrlByName(App.custom.build.homepage), trigger: true

    enableOverwrite: ->
      console.log 'overwrite enabled'
      backOverwrite = true

    disableOverwrite: ->
      console.log 'overwrite disabled'
      backOverwrite = false

  App.on "before:start", ->
    if App.device.isNative
      API.init()
