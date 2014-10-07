@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.Base extends App.Views.ItemView
    initialize: ->
      # Every prompt needs a gatherResponses method,
      # which will gather all response fields for the
      # response:get handler, activated when the prompt
      # needs to be validated.
      App.vent.on "survey:response:get", @gatherResponses

  class Prompts.BaseComposite extends App.Views.CompositeView
    initialize: ->
      App.vent.on "survey:response:get", @gatherResponses

  class Prompts.Text extends Prompts.Base
    template: "prompts/text"
    gatherResponses: (surveyId, stepId) =>
      response = @$el.find('input[type=text]').val()
      @trigger "response:submit", response, surveyId, stepId

  class Prompts.Number extends Prompts.Base
    template: "prompts/number"
    gatherResponses: (surveyId, stepId) =>
      response = @$el.find('input[type=text]').val()
      @trigger "response:submit", response, surveyId, stepId
    initialize: ->
      super
      @listenTo @, 'value:increment', @incrementValue
      @listenTo @, 'value:decrement', @decrementValue
    incrementValue: ->
      $valueField = @$el.find("input[type='text']")
      myVal = $valueField.val()
      myVal = if !!!myVal.length or _.isNaN(myVal) then 0 else parseInt(myVal)
      $valueField.val(myVal+1)
    decrementValue: ->
      $valueField = @$el.find("input[type='text']")
      myVal = $valueField.val()
      myVal = if !!!myVal.length or _.isNaN(myVal) then 0 else parseInt(myVal)
      $valueField.val(myVal-1)
    triggers:
      "click button.increment": "value:increment"
      "click button.decrement": "value:decrement"

  class Prompts.Timestamp extends Prompts.Base
    template: "prompts/timestamp"
    gatherResponses: (surveyId, stepId) =>
      myDate = @$el.find('input[type=date]').val()
      myTime = @$el.find('input[type=time]').val()
      myDateObj = new Date(Date.parse("#{myDate} #{myTime}"))
      console.log 'myDateObj', myDateObj
      response = myDateObj.toISOString()
      @trigger "response:submit", response, surveyId, stepId
    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data
      if data.currentValue
        data.currentDateValue = data.currentValue.toISOString().substring(0, 10).trim()
        data.currentTimeValue = data.currentValue.substring(11, 19).trim()
      else
        data.currentDateValue = new Date().toISOString().substring(0, 10).trim()
        data.currentTimeValue = new Date().toISOString().substring(11, 19).trim()
      data

  class Prompts.Photo extends Prompts.Base
    template: "prompts/photo"
    initialize: ->
      super

  class Prompts.SingleChoiceItem extends App.Views.ItemView
    tagName: 'li'
    template: "prompts/single_choice_item"

  # Prompt Single Choice
  class Prompts.SingleChoice extends Prompts.BaseComposite
    template: "prompts/single_choice"
    itemView: Prompts.SingleChoiceItem
    itemViewContainer: ".prompt-list"
    gatherResponses: (surveyId, stepId) =>
      response = @$el.find('input[type=radio]').filter(':checked').val()
      @trigger "response:submit", response, surveyId, stepId
    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @$el.find("input[value='#{currentValue}']").attr('checked', true)

  class Prompts.MultiChoiceItem extends App.Views.ItemView
    tagName: 'li'
    template: "prompts/multi_choice_item"

  # Prompt Multi Choice
  class Prompts.MultiChoice extends Prompts.SingleChoice
    template: "prompts/multi_choice"
    itemView: Prompts.MultiChoiceItem
    itemViewContainer: ".prompt-list"
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
          @$el.find("input[value='#{currentValue}']").attr('checked', true)
        )
      else
        @$el.find("input[value='#{valueParsed}']").attr('checked', true)

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

  # Prompt Single Choice Custom
  class Prompts.SingleChoiceCustom extends Prompts.BaseComposite
    initialize: ->
      super
      @listenTo @, 'choice:toggle', @toggleChoice
      @listenTo @, 'choice:add', @addChoice
      @listenTo @, 'choice:cancel', @cancelChoice
      # TODO: Make a mini validator for custom choice,
      # e.g. disallow duplicates
      @listenTo @, 'choice:add:invalid', (-> console.log 'invalid custom choice, please try again')
    toggleChoice: (args) ->
      $addForm = @$el.find '.add-form'
      $addForm.toggleClass 'hidden'

    cancelChoice: ->
      $addForm = @$el.find '.add-form'
      $addForm.addClass 'hidden'
      $addForm.find(".add-value").val('')
    addChoice: (args) ->
      $addForm = @$el.find '.add-form'
      myVal = $addForm.find(".add-value").val()

      if !!!myVal.length
        # ensure a new custom choice isn't blank.
        @trigger "choice:add:invalid"
        return false

      if not $addForm.hasClass 'hidden'

        # add new choice, based on the contents of the text prompt,
        # to the view's Collection. Validation and parsing takes
        # place within the ChoiceCollection's model.

        # Also, will add an event to clear the value of the input
        # on successful submit.

        args.collection.add([{
          "key": _.uniqueId()
          "label": myVal
          "parentId": args.model.get('id')
        }])

    template: "prompts/choice_custom"
    itemView: Prompts.SingleChoiceItem
    itemViewContainer: ".prompt-list"
    triggers:
      "click button.my-add": "choice:toggle"
      "click .add-form .add-submit": "choice:add"
      "click .add-form .add-cancel": "choice:cancel"
    gatherResponses: (surveyId, stepId) =>
      # reset the add custom form, if it's open
      @trigger "choice:cancel"
      # this expects the radio buttons to be in the format:
      # <li><input type=radio ... /><label>labelText</label></li>
      $checkedInput = @$el.find('input[type=radio]').filter(':checked')
      response = if !!$checkedInput.length then false else $checkedInput.parent().find('label').text()
      @trigger "response:submit", response, surveyId, stepId


  class Prompts.MultiChoiceCustom extends Prompts.SingleChoiceCustom
    itemView: Prompts.MultiChoiceItem
    extractJSONString: ($responses) ->
      # extract responses from the selected options
      # into a JSON string
      return false unless $responses.length > 0
      result = _.map($responses, (response) ->
        $(response).parent().find('label').text()
      )
      JSON.stringify result

    gatherResponses: (surveyId, stepId) =>
      # reset the add custom form, if it's open
      @trigger "choice:cancel"
      # this expects the checkbox buttons to be in the format:
      # <li><input type=checkbox ... /><label>labelText</label></li>
      $responses = @$el.find('input[type=checkbox]').filter(':checked')
      @trigger "response:submit", @extractJSONString($responses), surveyId, stepId
