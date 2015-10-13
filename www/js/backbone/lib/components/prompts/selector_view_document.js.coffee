@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.Document extends Prompts.Base
    template: "prompts/document"
    triggers:
      'change input[type=file]': "file:changed"

    initialize: ->
      super
      @listenTo @, 'file:changed', @processFile
      @listenTo @model, 'change:currentValue', @render

    processFile: ->
      fileDOM = @$el.find('input[type=file]')[0]
      myInput = fileDOM.files[0]

      if myInput
        # STOPGAP - file extension encoded in UUIDs

        if App.request("system:file:name:is:valid", myInput.name) and !App.request("system:file:name:is:video", myInput.name)

          fileExt = myInput.name.match(/\.[0-9a-z]+$/i)[0]

          @model.set 'currentValue',
            fileObj: myInput
            fileName: myInput.name
            UUID: App.request('system:file:generate:uuid', fileExt)
            # UUID: _.guid()
            fileSize: myInput.size

        else
          App.vent.trigger "system:file:ext:invalid", myInput.name
          @model.set 'currentValue', false
      else
        @model.set 'currentValue', false

    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data

      if !data.currentValue
        data.fileName= 'Select a Document File'
      else
        data.fileName = "Selected File: #{data.currentValue.fileName}"

      data

    gatherResponses: (surveyId, stepId) =>
      response = @model.get('currentValue')
      @trigger "response:submit", response, surveyId, stepId
