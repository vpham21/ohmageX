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

    addItem: (responseData, errorText, responses, surveyId) ->
      console.log 'addItem responseData', responseData

      surveyObj = JSON.parse responseData.surveys
      console.log 'surveyObj', surveyObj
      result =
        data: responseData
        timestamp: responseData.timestamp
        campaign_urn: responseData.campaign_urn
        campaign_creation_timestamp: responseData.campaign_creation_timestamp
        name: App.request('survey:saved:title', surveyId)
        description: App.request('survey:saved:description', surveyId)
        id: _.guid()
        errorText: errorText
        responses: responses

      currentQueue.add result
      @updateLocal( =>
        App.vent.trigger 'uploadqueue:add:success', result
      )

    removeItem: (id) ->
      currentQueue.remove currentQueue.get(id)
      @updateLocal( =>
        App.vent.trigger 'uploadqueue:remove:success', id
      )
    changeError: (id, errorText) ->
      console.log 'changeError id', id
      queueItem = currentQueue.get id
      queueItem.set 'errorText', errorText
      @updateLocal( =>
        App.vent.trigger 'uploadqueue:change:error:success', id
      )
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

  App.commands.setHandler "uploadqueue:item:add", (responseData, errorText, surveyId) ->
    responses = App.request 'responses:current:valid'
    API.addItem responseData, errorText, responses, surveyId

  App.commands.setHandler "uploadqueue:item:remove", (id) ->
    API.removeItem id

  App.commands.setHandler "uploadqueue:item:error:set", (id, errorText) ->
    API.changeError id, errorText

  App.reqres.setHandler "uploadqueue:entity", ->
    currentQueue

  App.reqres.setHandler "uploadqueue:item", (id) ->
    if !!!currentQueue.get(id) then throw new Error "item id #{id} does not exist in upload queue"
    currentQueue.get(id)

  App.reqres.setHandler "uploadqueue:length", ->
    currentQueue.length

  App.commands.setHandler "uploadqueue:clear", ->
    API.clear()

  App.vent.on "credentials:cleared", ->
    API.clear()
