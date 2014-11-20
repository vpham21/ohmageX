@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The upload Queue Entity deals with data relating to the upload Queue.

  currentQueue = false

  class Entities.UploadQueueItem extends Entities.Model
    defaults: ->
      return {
        timestamp: (new Date).getTime() # new items get the epoch time
        status: 'running' # All queue items are running unless otherwise
      }

  class Entities.UploadQueue extends Entities.Collection
    model: Entities.UploadQueueItem
    comparator: (item) ->
      item.get 'timestamp'

  API =
    init: ->
      App.request "storage:get", 'upload_queue', ((result) =>
        # user upload queue retrieved from raw JSON.
        console.log 'user upload queue retrieved from storage'
        currentQueue = new Entities.UploadQueue result
      ), =>
        console.log 'user upload queue not retrieved from storage'
        currentQueue = new Entities.UploadQueue

    addItem: (responseData, status) ->
      console.log 'addItem responseData', responseData

      result = 
        data: responseData
        name: 'test'
        id: _.guid()

      if status isnt false then result['status'] = status

      currentQueue.add result
      @updateLocal( =>
        App.vent.trigger 'uploadqueue:add:success', result
      )

    removeItem: (id) ->
      currentQueue.remove currentQueue.get(id)
      @updateLocal( =>
        App.vent.trigger 'uploadqueue:remove:success', id
      )
    changeStatus: (id, status) ->
      console.log 'changeStatus id', id
      queueItem = currentQueue.get id
      queueItem.set 'status', status
    updateLocal: (callback) ->
      # update localStorage index upload_queue with the current version of campaignsSaved entity
      App.execute "storage:save", 'upload_queue', currentQueue.toJSON(), callback
    clear: ->
      currentQueue = new Entities.UploadQueue

      App.execute "storage:clear", 'upload_queue', ->
        console.log 'user upload queue erased'
        App.vent.trigger "uploadqueue:cleared"

  App.on "before:start", ->
    API.init()

  App.commands.setHandler "uploadqueue:item:add", (responseData, status = false) ->
    API.addItem responseData, status

  App.commands.setHandler "uploadqueue:item:remove", (id) ->
    API.removeItem id

  App.commands.setHandler "uploadqueue:item:disable", (id) ->
    API.changeStatus id, 'stopped'

  App.commands.setHandler "uploadqueue:item:enable", (id) ->
    API.changeStatus id, 'running'

  App.reqres.setHandler "uploadqueue:entity", ->
    currentQueue

  App.commands.setHandler "uploadqueue:clear", ->
    API.clear()
