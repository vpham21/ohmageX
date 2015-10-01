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

    updateLocal: (callback) ->
      # update localStorage index file_meta with the current version of the file meta store
      App.execute "storage:save", 'file_meta', storedMeta.toJSON(), callback


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

