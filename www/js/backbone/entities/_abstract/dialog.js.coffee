@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  API =
    confirm: (message, activateCallback, cancelCallback) ->
      if App.device.isNative
        App.vent.trigger 'device:dialog:confirm:show'
        navigator.notification.confirm message, ((buttonIndex) ->
          if buttonIndex is 2
            App.vent.trigger 'device:dialog:confirm:close'
            activateCallback()
          else if cancelCallback isnt false
            App.vent.trigger 'device:dialog:confirm:close'
            cancelCallback()
        ), App.package_info.app_name, ['Cancel', 'OK']
      else
        if confirm(message)
          activateCallback()
        else if cancelCallback isnt false
          cancelCallback()
    alert: (message) ->
      if App.device.isNative
        App.vent.trigger 'device:dialog:alert:show'
        navigator.notification.alert message, (=>
          App.vent.trigger 'device:dialog:alert:close'
        ), App.package_info.app_name
      else
        alert(message)

  App.commands.setHandler "dialog:confirm", (message, activateCallback, cancelCallback = false) ->
    API.confirm message, activateCallback, cancelCallback

  App.commands.setHandler "dialog:alert", (message) ->
    API.alert message
