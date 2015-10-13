@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Systems File entity.
  # This provides the interface for system file handlers.

  fileDirectory = false

  API =
    init: ->
      fileDirectory = cordova.file.dataDirectory

    getFullPath: (uuid) ->
      # file directory, uuid, plus the encoded extension
      fileDirectory + uuid + App.request("system:file:uuid:ext", uuid)

    readFile: (options) ->
      window.resolveLocalFileSystemURL @getFullPath(options.uuid), options.success, options.error

    openFile: (uuid, type) ->
      console.log 'file path to open', @getFullPath(uuid)
      window.openFileNative.open @getFullPath(uuid)

    downloadFile: (options) ->
      _.defaults options,
        showLoader: true

      ft = new FileTransfer()

      if options.showLoader
        App.vent.trigger "loading:show", "Downloading..."

        ft.onprogress = (progressEvent) =>
          if progressEvent.lengthComputable
            # TODO: Refactor so download progress event is customizable.
            # Pass in a custom event label to trigger showing percentages
            # instead of directly triggering the loader.
            App.vent.trigger "loading:show", "Downloading #{Math.round(progressEvent.loaded / progressEvent.total * 100)}%..."

      ft.download options.url, @getFullPath(options.uuid), options.success, options.error

    removeFileByUUID: (uuid) ->
      window.resolveLocalFileSystemURL @getFullPath(uuid), ( (fileEntry) =>
        fileEntry.remove ( =>
          App.vent.trigger "system:file:uuid:remove:success", uuid
        ),( =>
          App.vent.trigger "system:file:uuid:remove:error", uuid
        )
      ),( =>
        App.vent.trigger "system:file:uuid:remove:error", uuid
      )

  App.on "before:start", ->
    if App.device.isNative then API.init()

  App.commands.setHandler "system:file:uuid:read", (options) ->
    # parameters:
    # uuid
    # success callback, arg is a fileEntry
    # error callback, arg is an error message
    API.readFile options

  App.commands.setHandler "system:file:uuid:download", (options) ->
    # parameters:
    # uuid
    # url
    # success callback, arg is a fileEntry
    # error callback, arg is an error message
    API.downloadFile options

  App.commands.setHandler "system:file:uuid:open", (uuid, type) ->
    # parameters:
    # uuid
    # type - MIME type
    API.openFile uuid, type

  App.commands.setHandler "system:file:uuid:remove", (uuid) ->
    API.removeFileByUUID uuid
