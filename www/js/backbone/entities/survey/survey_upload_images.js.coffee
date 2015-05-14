@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The survey Entity deals with data relating to a single survey.
  # This module handles image processing for a single survey upload.

  # currentImages
  currentImages = false
  lastUUID = false

  API =
    getLastUUID: ->
      if lastUUID isnt false then lastUUID else throw new Error "lastUUID is #{lastUUID} and currentImages is #{currentImages}"
    generateImgUUID: (img64) ->
      console.log 'generateImgUUID'
      # generate a UUID and put it into a group of UUIDs in this format:
      # { UUID: base64EncodedImage }
      lastUUID = _.guid()
      if !currentImages then currentImages = {}
      # truncate encoding prefix, if it exists
      truncatePrefixIndex = if img64.indexOf('base64,') isnt -1 then img64.indexOf('base64,')+7 else 0
      currentImages[lastUUID] = img64.substring truncatePrefixIndex
    getImagesString: ->
      if currentImages then JSON.stringify(currentImages) else '{}'

  App.commands.setHandler "survey:images:add", (img64) ->
    API.generateImgUUID img64

  App.reqres.setHandler "survey:images:string", ->
    API.getImagesString()

  App.reqres.setHandler "survey:images:uuid:last", ->
    API.getLastUUID()

  App.commands.setHandler "survey:images:destroy", ->
    currentImages = false
    lastUUID = false

  App.vent.on "survey:exit survey:reset", ->
    currentImages = false
    lastUUID = false
