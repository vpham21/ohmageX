@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This Entity handles upload processing for responses.

  class Entities.Uploader extends Entities.Model

  API =
    parseUploadErrors: (context, responseData, response, itemId) ->
      console.log 'parseUploadErrors'
      if response.result is "success"
        if context is 'survey'
          App.execute "survey:images:destroy"
          App.execute "survey:files:destroy"
        console.log 'Uploader Success!'
        App.vent.trigger "loading:hide"
        App.vent.trigger "#{context}:upload:success", response, itemId
      else
        console.log 'response.errors[0].code', response.errors[0].code
        type = switch response.errors[0].code
          when '0710','0703','0617','0700' then "campaign"
          when '0100' then "server"
          when '0600','0307','0302','0304' then "response"
          when '0200','0201','0202' then "auth"
        console.log 'type', type
        App.vent.trigger "loading:hide"
        App.vent.trigger "#{context}:upload:failure:#{type}", responseData, response.errors[0].text, itemId

    ajaxUploader: (context, responseData, itemId) ->

      # add auth credentials to the response before saving.
      # may later move this to the model's custom "sync" method.
      myAuth = App.request 'credentials:upload:params'
      throw new Error "Authentication credentials not set in uploader" if myAuth is false

      # uploader = new Entities.Uploader _.extend(myAuth, responseData)

      # Uses $.ajax() instead of Backbone.save() because of server error.
      # See Issue #208


      $.ajax
        type: 'POST' # not RESTful but the Ohmage 2.0 API requires it
        data: _.extend(myAuth, responseData)
        url: "#{App.request("serverpath:current")}/app/survey/upload"
        dataType: 'json'
        success: (response) =>
          @parseUploadErrors context, responseData, response, itemId
        error: (xhr, ajaxOptions, thrownError) =>
          console.log 'survey upload error'
          # assume all error callbacks here are network relate
          App.vent.trigger "loading:hide"
          App.vent.trigger "#{context}:upload:failure:network", responseData, xhr.status, itemId

    fileUploader: (context, responseData, itemId) ->

      # add auth credentials to the response before saving.
      # may later move this to the model's custom "sync" method.
      myAuth = App.request 'credentials:upload:params'
      throw new Error "Authentication credentials not set in uploader" if myAuth is false

      xhr = new XMLHttpRequest()
      xhr.upload.addEventListener 'progress',( (ev) =>
        App.vent.trigger "loading:show", "Uploading #{Math.round(ev.loaded / ev.total * 100)}%..."
      ), false

      xhr.upload.addEventListener 'loadend', (=> App.vent.trigger "loading:hide")

      xhr.onreadystatechange = (evt) =>
        if xhr.readyState is 4
          if xhr.status is 200
            @parseUploadErrors context, responseData, xhr.response, itemId
          else
            console.log 'survey upload error'
            # assume all error callbacks here are network relate
            App.vent.trigger "#{context}:upload:failure:network", responseData, xhr.upload.status, itemId

      myData = @xhrFormData _.extend(myAuth, responseData, App.request("survey:files"))
    xhrFormData: (responseObj) ->
      console.log 'xhrFormData responseObj', responseObj

      myData = new FormData()
      _.each responseObj, (value, key) ->
        # set all properties using the FormData API, including files
        myData.append key, value

      myData

  App.commands.setHandler "uploader:new", (context, responseData, itemId) ->
    # context is a means of determining the 
    # execution context of the `uploader:new` command.
    # 'survey' - it's launched from a survey context.
    # 'uploadqueue' - it's launched from the upload queue.

    # itemId
    # in a 'survey' context, this is a reference to the surveyId.
    # in an 'uploadqueue' context, this is a reference to the queue item's
    # model id.
    App.vent.trigger "loading:show", "Submitting Survey..."

    if App.request("responses:contains:file")
      API.fileUploader context, responseData, itemId
    else
      API.ajaxUploader context, responseData, itemId
