@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.BaseComposite extends App.Views.CompositeView
    initialize: ->
      App.vent.on "survey:response:get", (surveyId, stepId) =>
        if stepId is @model.get('id') then @gatherResponses(surveyId, stepId)


  class Prompts.SingleChoiceItem extends App.Views.ItemView
    tagName: 'tr'
    template: "prompts/single_choice_item"
    triggers:
      "click button.delete": "customchoice:remove"


  class Prompts.SingleChoice extends Prompts.BaseComposite
    template: "prompts/single_choice"
    childView: Prompts.SingleChoiceItem
    childViewContainer: ".prompt-list"

    selectChosen: (currentValue) ->
      # activate a choice selection based on the currentValueType.
      myChosenValue = switch @model.get('currentValueType')
        when 'response'
          # Saved responses are formatted as an object.
          # Reference the key property.
          currentValue.key
        when 'default'
          # Default responses are formatted as an individual key.
          # Just use the raw value.
          currentValue

      @$el.find("input[value='#{myChosenValue}']").prop('checked', true)

    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @selectChosen currentValue

    getResponseMeta: ->

      $checkedInput = @$el.find('input[type=radio]').filter(':checked')

      if !!!$checkedInput.length then return false

      myKey = $checkedInput.val()

      return {
        key: if isNaN(myKey) then myKey else parseInt(myKey)
        label: $checkedInput.parent().parent().find('label.canonical').text()
      }

    gatherResponses: (surveyId, stepId) =>
      @trigger "response:submit", @getResponseMeta(), surveyId, stepId


  class Prompts.MultiChoiceItem extends Prompts.SingleChoiceItem
    template: "prompts/multi_choice_item"


  class Prompts.MultiChoice extends Prompts.SingleChoice
    template: "prompts/multi_choice"
    childView: Prompts.MultiChoiceItem
    childViewContainer: ".prompt-list"
    selectCurrentValues: (currentValues) ->

      if currentValues.indexOf(',') isnt -1 and currentValues.indexOf('[') is -1
        # Check for values that contain a comma-separated list of
        # numbers with NO brackets (multi_choice default allows this)
        # which isn't a proper JSON format to convert to an array.
        # Add the missing brackets.
        currentValues = "[#{currentValues}]"

      try
        valueParsed = JSON.parse(currentValues)
      catch Error
        console.log "Error, saved response string #{currentValues} failed to convert to array. ", Error
        return false

      if Array.isArray valueParsed
        # set all the array values
        _.each(valueParsed, (currentValue) =>
          console.log 'currentValue', currentValue
          @$el.find("input[value='#{currentValue}']").prop('checked', true)
        )
      else
        @$el.find("input[value='#{valueParsed}']").prop('checked', true)

    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @selectCurrentValues currentValue

    extractJSONString: ($responses) ->
      # extract responses from the selected options
      # into a JSON string
      return false unless $responses.length > 0
      result = _.map($responses, (response) ->
        parseInt $(response).val()
      )
      JSON.stringify result

    gatherResponses: (surveyId, stepId) =>
      $responses = @$el.find('input[type=checkbox]').filter(':checked')
      @trigger "response:submit", @extractJSONString($responses), surveyId, stepId
