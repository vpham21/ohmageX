@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The FileMeta entity stores meta information about stored files on the device.
  # Currently the File Meta store does not erase on logout like other components.
  # Only the user can erase it.

  class Entities.FileMetaEntry extends Entities.Model

  class Entities.FileMeta extends Entities.Collection
    model: Entities.FileMetaEntry


  storedMeta = false

  API =
    init: ->
      App.request "storage:get", 'file_meta', ((result) =>
        console.log 'saved file meta retrieved from storage'
        storedMeta = new Entities.FileMeta result
        App.vent.trigger "filemeta:saved:init:success"
      ), =>
        console.log 'saved file meta not retrieved from storage'
        storedMeta = new Entities.FileMeta
        App.vent.trigger "filemeta:saved:init:failure"

    getFileMetaLength: ->
      storedMeta.length

    generateMediaURL: (uuid, context) ->

      myData =
        client: App.client_string
        id: uuid
      myData = _.extend(myData, App.request("credentials:upload:params"))

      myURL = "#{App.request("serverpath:current")}/app/#{context}/read?#{$.param(myData)}"
      myURL

    addFileMeta: (options) ->
      storedMeta.add options
      @updateLocal( =>
        console.log "file meta API.addFileMeta storage success"
      )

    updateLocal: (callback) ->
      # update localStorage index file_meta with the current version of the file meta store
      App.execute "storage:save", 'file_meta', storedMeta.toJSON(), callback

    fetchImageFileURL: (uuid) ->

      App.execute "system:file:uuid:read",
        uuid: uuid
        success: (fileEntry) =>
          App.vent.trigger "file:image:url:success", uuid, fileEntry.toURL()
        error: (message) =>
          # file wasn't read, try to download it.
          App.vent.trigger "file:image:uuid:notfound", uuid

          App.execute "system:file:uuid:download",
            uuid: uuid
            url: @generateMediaURL(uuid, 'image')
            success: (fileEntry) =>
              App.vent.trigger "file:image:url:success", uuid, fileEntry.toURL()

              @addFileMeta
                id: uuid
                username: App.request("credentials:username")
            error: =>
              App.vent.trigger "file:image:url:error", uuid

    clear: ->

      # erase all stored file entries one at a time.
      storedMeta.each (fileMetaEntry) =>
        # don't need to pass callbacks to removal. Removal just happens in the background.
        App.execute "system:file:uuid:remove", fileMetaEntry.get('id')

      storedMeta = new Entities.FileMeta

      App.execute "storage:clear", 'file_meta', ->
        console.log 'file meta erased'
        App.vent.trigger "filemeta:saved:cleared"

  App.on "before:start", ->
    API.init()

  App.commands.setHandler "filemeta:erase:all", ->
    metaLength = API.getFileMetaLength()
    if metaLength > 0
      App.execute "dialog:confirm", "Are you sure you want to clear the file cache? You will lose #{metaLength} file(s).", (=>
        API.clear()
      ), (=>
        console.log 'dialog canceled'
      )

