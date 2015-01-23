@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Permissions entity.
  # This pertains to device-specific permissions.

  class Entities.Permission extends Entities.Model
    defaults:
      localNotification: false

  currentPermissions = false

  API =
    init: ->
      API.addRefreshCheck()

      App.request "storage:get", 'permissions', ((result) =>
        # saved permissions retrieved from raw JSON.
        console.log 'saved permissions retrieved from storage'
        currentPermissions = new Entities.Permission result
        App.vent.trigger "permissions:saved:init:success"
        API.checkPermissions()
      ), =>
        console.log 'saved permissions not retrieved from storage'
        currentPermissions = new Entities.Permission
          id: '123'
          created: "1421355183"
          startDateTime: (new Date).getTime()+30000
        App.vent.trigger "permissions:saved:init:failure"
        API.checkPermissions()

    addRefreshCheck: ->
      document.addEventListener 'resume', (=>
        API.checkPermissions()
        console.log 'ADDREFRESHCHECK'
      )
    checkPermissions: ->
      window.plugin.notification.local.hasPermission((granted) =>
        currentPermissions.set 'localNotification', granted
        currentPermissions.trigger "localnotification:checked"

        App.execute "storage:save", 'permissions', currentPermissions.toJSON(), =>
          App.vent.trigger "permissions:localnotification:checked", granted
          console.log 'current saved CHECKED permissions', granted
      )

    registerLocalNotifications: ->
      window.plugin.notification.local.registerPermission((granted) =>
        currentPermissions.set 'localNotification', granted
        currentPermissions.trigger "localnotification:registered"

        App.execute "storage:save", 'permissions', currentPermissions.toJSON(), =>
          App.vent.trigger "permissions:localnotifications:registered", granted
          console.log 'current saved REGISTERED permissions', granted
      )

    getPermissions: ->
      currentPermissions

    clear: ->
      currentPermissions = new Entities.Permission

      App.execute "storage:clear", 'permissions', ->
        console.log 'saved permissions erased'
        App.vent.trigger "permissions:saved:cleared"

  App.on "before:start", ->
    if App.device.isNative
      API.init()

  App.commands.setHandler "permissions:saved:clear", ->
    if App.device.isNative
      API.clear()

  App.reqres.setHandler "permissions:current", ->
    if App.device.isNative
      API.getPermissions()

  App.commands.setHandler "permissions:register:localnotifications", ->
    if App.device.isNative
      API.registerLocalNotifications()
