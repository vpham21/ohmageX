@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Contains handlers for generating a Prompt Entity from individual Prompt XML.
  # uses Prompt entity definitions in prompt.js.coffee.

  API =
    isChoicePrompt: (promptType) ->
      switch promptType
        when "single_choice", "single_choice_custom", "multi_choice", "multi_choice_custom"
          return true
        else return false

    getPromptEntity: (promptType, $promptXML) ->
      # Based on getPrompt() method in prompt.js.coffee
      # TODO: Remove getPrompt() method when removing Dashboard code
      result = {}
      isChoice = @isChoicePrompt promptType
      myId = $promptXML.tagText('id')
      propertiesFound = false

      # iterate through all prompt XML children.
      # return an object containing the parsed result of all prompt tags ready for
      # conversion into an instance of Entities.Prompt

      $promptXML.children().each(() ->
        $myEl = $(@)
        myTag = $myEl.prop("tagName")
        myValue = $myEl.text()

        if myTag is "properties"
          propertiesFound = true
          $properties = $myEl.find("property")
          if isChoice
            # All properties should be part of a ChoiceCollection
            # for rendering Choices within a Choice prompt layout.
            propArr = []
            $properties.each( ->
              propArr.push({
                "key": $(@).tagText("key")
                "label": $(@).tagText("label")
                "parentId": myId
              })
            )
            myValue = new Entities.ChoiceCollection propArr
          else
            # All properties represent values that are attributes,
            # not values to be rendered sequentially.
            propObj = {}
            $properties.each( ->
              propObj[$(@).tagText("key")] = $(@).tagText('label')
            )
            myValue = propObj
        result[myTag] = myValue
      )
      # add handler if the properties tag (which is apparently optional
      # in some circumstances) is not found
      if not propertiesFound
        if isChoice
          result['properties'] = new Entities.ChoiceCollection []
        else
          result['properties'] = {}

      new Entities.Prompt result

  App.reqres.setHandler "prompt:entity", (promptType, $promptXML) ->
    API.getPromptEntity promptType, $promptXML