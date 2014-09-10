@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The prompt entity currently contains the most logic, and some of this
  # logic will be sectioned into other modules as it grows.
  # It requests XML from the abstracted XML entity, and then performs
  # some parsing on individual tags within a requested prompt's XML,
  # converting them into the appropriate entities.

  class Entities.ChoiceModel extends Entities.Model

  class Entities.ChoiceCollection extends Entities.Collection
    model: Entities.ChoiceModel

  class Entities.PromptProperty extends Entities.Model

  class Entities.Prompt extends Entities.Model
    initialize: (options) ->
      @set 'skippable', if options.skippable is 'true' then true else false
      if not (options.properties instanceof Entities.ChoiceCollection)
        # If it's a ChoiceCollection, it's a list of items to be rendered,
        # not a PromptProperty, so don't overwrite it
        @set 'properties', new Entities.PromptProperty options.properties

  API =
    isChoicePrompt: (promptType) ->
      switch promptType
        when "single_choice", "single_choice_custom", "multi_choice", "multi_choice_custom"
          return true
        else return false
    getPrompt: (position) ->
      prompts = App.request 'xml:get', 'prompt'
      $samplePrompt = $( prompts[ position ] )
      result = {}
      $myType = $samplePrompt.find('promptType')
      isChoice = @isChoicePrompt $myType.text()
      myId = $samplePrompt.find("id").text()

      $samplePrompt.children().each(() ->
        myElement = $(@)
        myTag = myElement.prop("tagName")
        myValue = myElement.text()

        if myTag is "properties"
          $properties = $(@).find("property")
          if isChoice
            # All properties should be part of a ChoiceCollection
            # for rendering Choices within a Choice prompt layout.
            propArr = []
            $properties.each(() ->
              propArr.push({
                "key": $(@).find("key").text()
                "label": $(@).find("label").text()
                "parentId": myId
              })
            )
            myValue = new Entities.ChoiceCollection propArr
          else
            # All properties represent values that are attributes,
            # not values to be rendered sequentially.
            propObj = {}
            $properties.each(() ->
              propObj[$(@).find("key").text()] = $(@).find('label').text()
            )
            myValue = propObj

        result[myTag] = myValue
      )
      new Entities.Prompt result

  App.reqres.setHandler "prompt:get", (position) ->
    API.getPrompt position