@Ohmage.module "Uploadqueue", (Uploadqueue, App, Backbone, Marionette, $, _) ->

  class Uploadqueue.Router extends Marionette.AppRouter
    before: ->
      surveyActive = App.request "surveytracker:active"
      if surveyActive
        if confirm('do you want to exit the survey?')
          # reset the survey's entities.
          App.vent.trigger "survey:reset"
        else
          # They don't want to exit the survey, cancel.
          # Move the history to its previous URL.
          App.historyPrevious()
          return false
    appRoutes:
      "uploadqueue": "list"

  API =
    list: (campaign_id) ->
      App.vent.trigger "nav:choose", "Upload Queue"
      new Uploadqueue.List.Controller
    queueFailureGeneral: (responseData, errorPrefix, errorText, itemId) ->
      # show notice that it failed.
      console.log 'uploadqueue:upload:failure:campaign itemId', itemId

      # a campaign error upload can be attempted again, enable
      # uploading if it's not enabled already.
      App.execute "uploadqueue:item:enable", itemId
      App.execute "notice:show",
        data:
          title: "Response Upload Error"
          description: "Problem with Response: #{errorPrefix} #{errorText}"

  App.addInitializer ->
    new Uploadqueue.Router
      controller: API

  App.vent.on "upload:queue:start", (model) ->
    console.log 'test'

  App.vent.on "uploadqueue:list:stopped:clicked", (model) ->
    App.execute "notice:show",
      data:
        title: "Delete Response"
        description: "This response is unable to be uploaded. Delete it?"
        showCancel: true
      okListener: =>
        App.execute "uploadqueue:item:remove", model.get('id')

  App.vent.on "uploadqueue:list:running:clicked", (model) ->
    # do something when a running queue item's title is clicked

  App.vent.on "uploadqueue:list:delete:clicked", (model) ->
    App.execute "notice:show",
      data:
        title: "Delete Response"
        description: "It's possible to try uploading this response again. Delete it anyway?"
        showCancel: true
      okListener: =>
        App.execute "uploadqueue:item:remove", model.get('id')

  App.vent.on "uploadqueue:list:upload:clicked", (model) ->
    console.log 'uploadqueue:list:upload:clicked model', model
    App.execute "uploader:new", 'uploadqueue', model.get('data'), model.get('id')

  App.vent.on "uploadqueue:upload:success", (response, itemId) ->
    # remove the uploaded item from the queue
    App.execute "uploadqueue:item:remove", itemId

  App.vent.on "uploadqueue:upload:failure:campaign", (responseData, errorText, itemId) ->
    API.queueFailureCampaign responseData, errorText, itemId

  App.vent.on "uploadqueue:upload:failure:response", (responseData, errorText, itemId) ->
    # placeholder for response errors handler.

  App.vent.on "uploadqueue:upload:failure:server", (responseData, errorText, itemId) ->
    # placeholder for server errors handler.

  App.vent.on "uploadqueue:upload:failure:auth", (responseData, errorText, surveyId) ->
    # placeholder for auth errors handler.

  App.vent.on "uploadqueue:upload:failure:network", (responseData, errorText, surveyId) ->
    # placeholder for network errors handler.

