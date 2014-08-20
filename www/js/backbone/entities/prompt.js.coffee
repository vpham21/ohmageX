@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Prompt extends Entities.Model

  API =
    getPrompt: ->
      prompts = App.request 'xml:get', 'prompt'
      $samplePrompt = $( prompts[0] )
      result = {}
      $samplePrompt.children().each(() ->
        myElement = $(this)
        myTag = myElement.prop("tagName")
        # add properties support to element later
        if myTag isnt "properties" then result[myTag] = myElement.text()
      )
      new Entities.Prompt result

  App.reqres.setHandler "prompt:get", ->
    API.getPrompt()