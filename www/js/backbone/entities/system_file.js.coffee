@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems File entity.
  # This provides the interface for system file handlers.

  fileDirectory = false

  API =
    init: ->
      fileDirectory = cordova.file.dataDirectory

    readFile: (options) ->
      window.resolveLocalFileSystemURL fileDirectory + options.uuid, options.success, options.error


  App.on "before:start", ->
    if App.device.isNative then API.init()

  App.commands.setHandler "system:file:uuid:read", (options) ->
    # parameters:
    # uuid
    # success callback, arg is a fileEntry
    # error callback, arg is an error message
    API.readFile options
