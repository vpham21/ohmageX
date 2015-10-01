@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems File entity.
  # This provides the interface for system file handlers.

  fileDirectory = false

  API =
    init: ->
      fileDirectory = cordova.file.dataDirectory


  App.on "before:start", ->
    if App.device.isNative then API.init()
