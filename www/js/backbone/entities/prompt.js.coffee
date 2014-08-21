@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.PromptProperty extends Entities.Model

  class Entities.Prompt extends Entities.Model
    initialize: (options) ->
      @set 'properties', new Entities.PromptProperty options.properties
      @set 'skippable', if options.skippable is 'true' then true else false

  API =
    getPrompt: (position) ->
      prompts = App.request 'xml:get', 'prompt'
      $samplePrompt = $( prompts[ position ] )
      result = {}
      $samplePrompt.children().each(() ->
        myElement = $(this)
        myTag = myElement.prop("tagName")
        myValue = myElement.text()

        if myTag is "properties"
          $properties = $(this).find("property")
          propObj = {}
          $properties.each(() ->
            propObj[$(this).find("key").text()] = $(this).find('label').text()
          )
          myValue = propObj

        result[myTag] = myValue
      )
      new Entities.Prompt result

  App.reqres.setHandler "prompt:get", (position) ->
    API.getPrompt position