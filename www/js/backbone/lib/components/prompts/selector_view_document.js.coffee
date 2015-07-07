@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.Document extends Prompts.Base
    initialize: ->
      super
      @listenTo @, 'get:native:file', @getNativeFile
      @listenTo @, 'file:changed', @processFile
    template: "prompts/document"
    triggers: ->
      # if App.device.isNative
      #   return 'click .input-activate .get-file': "get:native:file"
      # else
      return 'change input[type=file]': "file:changed"

    getNativeFile: ->
      console.log 'get Native File'

    processFile: ->
      fileDOM = @$el.find('input[type=file]')[0]
      myInput = fileDOM.files[0]

      if myInput
        @model.set 'currentValue',
          fileObj: myInput
          fileName: myInput.name
          UUID: _.guid()
          fileSize: myInput.size
      else
        @model.set 'currentValue', false

    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data

      # data.nativeFilePicker = App.device.isNative and device.platform is ""
      data.nativeFilePicker = false

      if !data.currentValue
        data.fileName= 'Select a Document File'
      else
        data.fileName = data.currentValue.fileName

      data

    gatherResponses: (surveyId, stepId) =>
      response = @model.get('currentValue')
      @trigger "response:submit", response, surveyId, stepId
