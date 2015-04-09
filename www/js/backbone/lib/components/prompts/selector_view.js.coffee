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
      response = @$el.find('textarea').val()
      @trigger "response:submit", response, surveyId, stepId
    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data
      if !data.currentValue
        data.currentValue = ''
      data

  class Prompts.Number extends Prompts.Base
    template: "prompts/number"
    gatherResponses: (surveyId, stepId) =>
      response = @$el.find('input[type="number"]').val()
      @trigger "response:submit", response, surveyId, stepId
    initialize: ->
      super
      @listenTo @, 'value:increment', @incrementValue
      @listenTo @, 'value:decrement', @decrementValue
    incrementValue: ->
      $valueField = @$el.find("input[type='number']")
      myVal = $valueField.val()
      myVal = if !!!myVal.length or _.isNaN(myVal) then 0 else parseInt(myVal)
      if @model.get('properties').get('max') isnt undefined
        return if parseInt(@model.get('properties').get('max')) <= myVal
      $valueField.val(myVal+1)
    decrementValue: ->
      $valueField = @$el.find("input[type='number']")
      myVal = $valueField.val()
      myVal = if !!!myVal.length or _.isNaN(myVal) then 0 else parseInt(myVal)
      if @model.get('properties').get('min') isnt undefined
        return if parseInt(@model.get('properties').get('min')) >= myVal
      $valueField.val(myVal-1)
    triggers:
      "click button.increment": "value:increment"
      "click button.decrement": "value:decrement"
    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data
      if !data.currentValue
        data.currentValue = ''
      data.min = false
      data.max = false

      if @model.get('properties').get('min') isnt undefined and @model.get('properties').get('max') isnt undefined
        data.min = @model.get('properties').get('min')
        data.max = @model.get('properties').get('max')

      data

  class Prompts.Timestamp extends Prompts.Base
    template: "prompts/timestamp"
    gatherResponses: (surveyId, stepId) =>
      myDate = @$el.find('input[type=date]').val()
      myTime = @$el.find('input[type=time]').val()
      offset = new Date().toString().match(/([-\+][0-9]+)\s/)[1]
      response = "#{myDate} #{myTime}#{offset}"
      @trigger "response:submit", response, surveyId, stepId
    padWithZero: (number) ->
      if number < 10 then '0'+number else number
    serializeData: ->
      data = @model.toJSON()
      console.log 'serializeData data', data
      if data.currentValue
        currentDate = new Date(data.currentValue)
        data.currentDateValue = data.currentValue.substring(0,10)
      else
        currentDate = new Date()
        dd = @padWithZero(currentDate.getDate())
        mm = @padWithZero(currentDate.getMonth()+1) # January is 0
        yyyy = currentDate.getFullYear()

        # browser environment date input checks
        if (Modernizr.inputtypes.date)
          # use a value that will be detected and converted
          # by the browser datepicker.
          data.currentDateValue = "#{yyyy}-#{mm}-#{dd}"
        else
          # no native support for input type 'date'.
          # Set the value in the proper format.
          data.currentDateValue = "#{mm}/#{dd}/#{yyyy}"

      data.currentTimeValue = "#{@padWithZero(currentDate.getHours())}:#{@padWithZero(currentDate.getMinutes())}:#{@padWithZero(currentDate.getSeconds())}"
      data


  class Prompts.Photo extends Prompts.Base
    template: "prompts/photo"
    initialize: ->
      super
      @listenTo @, "file:changed", @processFile
      @listenTo @, "mobile:get", @getMobileImage
    processFile: ->
      fileDOM = @$el.find('input[type=file]')[0]
      myInput = fileDOM.files[0]
      _URL = window.URL || window.webkitURL
      maxDimension = @model.get('properties').get('maxDimension')
      if !!!maxDimension then maxDimension = 800
      img = new Image()
      imgCanvas = @$el.find('canvas')[0]

      if myInput
        if myInput.type in ['image/jpeg','image/png']
          img.onload = =>
            # resize image if exceeds max dimension
            if img.width > maxDimension or img.height > maxDimension
              ratio = Math.min(maxDimension / img.width, maxDimension / img.height)
              img.width = img.width * ratio
              img.height = img.height * ratio
            # place image on canvas, base64 encode
            context = imgCanvas.getContext('2d')
            context.clearRect 0, 0, imgCanvas.width, imgCanvas.height
            imgCanvas.width = img.width
            imgCanvas.height = img.height
            context.drawImage img, 0, 0, img.width, img.height
            @recordImage imgCanvas.toDataURL('image/jpeg',.5)

          img.src = _URL.createObjectURL myInput
        else
          console.log 'Please upload an image in jpeg or png format.'
      else
        console.log 'Please select an image.'
    getMobileImage: ->
      # Take picture using device camera and retrieve image as base64-encoded string
      console.log 'getMobileImage method'
      navigator.camera.getPicture ((img64) =>
        # success callback
        @recordImage "data:image/jpeg;base64,#{img64}"

      ),((message) =>
        # error callback
        window.setTimeout (=>
          # setTimeout hack required to display alerts properly in iOS camera callbacks
          App.execute "dialog:alert", "Failed to get image: #{message}"
        ), 0
      ),
        quality: 50
        allowEdit: false
        destinationType: navigator.camera.DestinationType.DATA_URL
    recordImage: (img64) ->
      @model.set('currentValue', img64)
      @renderImageThumb img64
    onRender: ->
      savedImage = @model.get('currentValue')
      if savedImage then @renderImageThumb(savedImage)
      if App.device.isNative
        # hide the input button on native so the "Get Photo"
        # button beneath it can activate
        @$el.find('.input-activate input').hide()

    renderImageThumb: (img64) ->
      # display the image in the preview
      $img = @$el.find '.preview-image'
      $img.prop 'src', img64
      $img.css 'display', 'block'
    gatherResponses: (surveyId, stepId) =>
      response = @model.get('currentValue')
      @trigger "response:submit", response, surveyId, stepId

    triggers: ->
      if App.device.isNative
        return 'click .input-activate button': "mobile:get"
      else
        return 'change input[type=file]': "file:changed"

  class Prompts.SingleChoiceItem extends App.Views.ItemView
    tagName: 'tr'
    template: "prompts/single_choice_item"
    triggers:
      "click button.delete": "customchoice:remove"

  # Prompt Single Choice
  class Prompts.SingleChoice extends Prompts.BaseComposite
    template: "prompts/single_choice"
    childView: Prompts.SingleChoiceItem
    childViewContainer: ".prompt-list"
    gatherResponses: (surveyId, stepId) =>
      response = @$el.find('input[type=radio]').filter(':checked').val()
      @trigger "response:submit", response, surveyId, stepId
    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @$el.find("input[value='#{currentValue}']").prop('checked', true)

  class Prompts.MultiChoiceItem extends Prompts.SingleChoiceItem
    template: "prompts/multi_choice_item"


  # Prompt Multi Choice
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

  # Prompt Single Choice Custom
  class Prompts.SingleChoiceCustom extends Prompts.BaseComposite
    initialize: ->
      super
      @listenTo @, 'customchoice:toggle', @toggleChoice
      @listenTo @, 'customchoice:add', @addChoice
      @listenTo @, 'customchoice:cancel', @cancelChoice

      @listenTo @, 'childview:customchoice:remove', @removeChoice

      @listenTo @, 'customchoice:add:invalid', (-> App.execute "dialog:alert", 'invalid custom choice, please try again.')
      @listenTo @, 'customchoice:add:exists', (-> App.execute "dialog:alert", 'Custom choice exists, please try again.')
    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @chooseValue currentValue
    chooseValue: (currentValue) ->
      # activate a choice selection based on the currentValueType.
      switch @model.get('currentValueType')
        when 'response'
          # Saved responses use the label, not the key.
          matchingValue = @$el.find("label:containsExact('#{currentValue}')").parent().parent().find('input').prop('checked', true)
        when 'default'
          # Default responses match keys instead of labels.
          # Select based on value.
          @$el.find("input[value='#{currentValue}']").prop('checked', true)

    removeChoice: (args) ->
      value = args.model.get 'label'
      @collection.remove @collection.where(label: value)
      @trigger "customchoice:remove", value
    toggleChoice: (args) ->
      $addForm = @$el.find '.add-form'
      $addForm.toggleClass 'hidden'

    cancelChoice: ->
      $addForm = @$el.find '.add-form'
      $addForm.addClass 'hidden'
      $addForm.find(".add-value").val('')
    addChoice: (args) ->
      $addForm = @$el.find '.add-form'
      myVal = $addForm.find(".add-value").val().trim()

      if !!!myVal.length
        # ensure a new custom choice isn't blank.
        @trigger "customchoice:add:invalid"
        return false

      if not $addForm.hasClass 'hidden'

        # add new choice, based on the contents of the text prompt,
        # to the view's Collection. Validation and parsing takes
        # place within the ChoiceCollection's model.

        if args.collection.where(label: myVal).length > 0
          # the custom choice already exists
          @trigger "customchoice:add:exists"
          return false

        args.collection.add([{
          "key": _.uniqueId()
          "label": myVal
          "parentId": args.model.get('id')
          "custom": true
        }])

        # clear the input on successful submit.
        @trigger "customchoice:add:success", myVal
        $addForm.find(".add-value").val('')
    template: "prompts/choice_custom"
    childView: Prompts.SingleChoiceItem
    childViewContainer: ".prompt-list"
    triggers:
      "click button.my-add": "customchoice:toggle"
      "click .add-form .add-submit": "customchoice:add"
      "click .add-form .add-cancel": "customchoice:cancel"
    gatherResponses: (surveyId, stepId) =>
      # reset the add custom form, if it's open
      @trigger "customchoice:cancel"
      # this expects the radio buttons to be in the format:
      # <li><input type=radio ... /><label>labelText</label></li>
      $checkedInput = @$el.find('input[type=radio]').filter(':checked')
      response = if !!!$checkedInput.length then false else $checkedInput.parent().parent().find('label').text()
      @trigger "response:submit", response, surveyId, stepId


  class Prompts.MultiChoiceCustom extends Prompts.SingleChoiceCustom
    childView: Prompts.MultiChoiceItem
    extractJSONString: ($responses) ->
      # extract responses from the selected options
      # into a JSON string
      return false unless $responses.length > 0
      result = _.map($responses, (response) ->
        $(response).parent().parent().find('label').text()
      )
      JSON.stringify result
    selectCurrentValues: (currentValues) ->

      valueType = @model.get 'currentValueType'

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
          # method from parent SingleChoiceCustom
          @chooseValue currentValue
        )
      else
        # method from parent SingleChoiceCustom
        @chooseValue valueParsed

    onRender: ->
      currentValue = @model.get('currentValue')
      if currentValue then @selectCurrentValues currentValue
    gatherResponses: (surveyId, stepId) =>
      # reset the add custom form, if it's open
      @trigger "customchoice:cancel"
      # this expects the checkbox buttons to be in the format:
      # <li><input type=checkbox ... /><label>labelText</label></li>
      $responses = @$el.find('input[type=checkbox]').filter(':checked')
      @trigger "response:submit", @extractJSONString($responses), surveyId, stepId

  class Prompts.Unsupported extends Prompts.Base
    className: "text-container"
    template: "prompts/unsupported"
    gatherResponses: (surveyId, stepId) =>
      # just submit an unsupported prompt response as "NOT_DISPLAYED".
      # The status within Flow isn't actually set as "not_displayed"
      # because we still need to render the unsupported prompt
      # placeholder. Also, this is a Prompt because we still need
      # to submit a value for this Response inside the Response object.
      @trigger "response:submit", "NOT_DISPLAYED", surveyId, stepId
