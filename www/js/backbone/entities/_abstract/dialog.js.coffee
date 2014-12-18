@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  API =
    confirm: (message, activateCallback, cancelCallback) ->
      if App.device.isNative
        navigator.notification.confirm message, ((buttonIndex) ->
          if buttonIndex is 2 then activateCallback()
          else if cancelCallback isnt false then cancelCallback()
        ), 'Confirm', ['Cancel', 'OK']
      else
        if confirm(message)
          activateCallback()
        else if cancelCallback isnt false
          cancelCallback()

  App.commands.setHandler "dialog:confirm", (message, activateCallback, cancelCallback = false) ->
    API.confirm message, activateCallback, cancelCallback
