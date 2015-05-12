@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to a single survey.
  # This module handles file processing for a single survey upload.

  # currentFiles
  currentFiles = false
  lastUUID = false

  API =
    addSurveyFile: (responseValue) ->
      if !currentFiles then currentFiles = {}
      currentFiles[responseValue.UUID] = responseValue.fileObj
    getFilesHash: ->
      console.log 'currentFiles', currentFiles
      if !currentFiles then throw new Error "Files hash is empty"
      currentFiles

  App.commands.setHandler "survey:file:add", (responseValue) ->
    API.addSurveyFile responseValue

  App.reqres.setHandler "survey:files", ->
    API.getFilesHash()

  App.commands.setHandler "survey:files:destroy", ->
    currentFiles = false
