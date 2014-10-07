@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.

  # currentResponses
  # "responses:init" initializes a ResponseCollection that persists in memory.
  # This collection is removed with "responses:destroy"
  currentResponses = false

  class Entities.ResponseProperty extends Entities.Model
    # response properties for validation

  class Entities.Response extends Entities.Model
    defaults: # default values for all Responses:
      response: false # All responses are false by default, updated with status before upload
      # properties: the getValidationProperties method initializes this
      # type: the promptType

  class Entities.ResponseValidated extends Entities.Response
    validate: (attrs, options, rulesMap) ->
      # this expects the options to contain options.properties.
      # properties are in the format [{propName: value}]
      # the RulesMap is an object that maps each of these properties
      # to a specific Rule defined in Entities.ValidationRules
      myProperties = {}
      _.each(rulesMap, (propName, ruleName) ->
        if attrs.properties[propName]?
          myProperties[ruleName] = attrs.properties[propName]
      )
      console.log 'myProperties', myProperties
      RulesChecker = new Entities.ValidationRules
        value: attrs.response
        rulesMap: myProperties
      if RulesChecker.errors.length > 0
        return RulesChecker.errors
      # this does not return if there are no errors,
      # because the BB Model validate method
      # only succeeds when nothing is returned
      return

  class Entities.TextResponse extends Entities.ResponseValidated
    validate: (attrs, options) ->
      myRulesMap =
        minLength: 'min'
        maxLength: 'max'
      super attrs, options, myRulesMap

  class Entities.NumberResponse extends Entities.ResponseValidated
    validate: (attrs, options) ->
      # set wholeNumber to default to false
      if !attrs.properties.wholeNumber? then attrs.properties.wholeNumber = "false"
      myRulesMap =
        minValue: 'min'
        maxValue: 'max'
        wholeNumber: 'wholeNumber'
      super attrs, options, myRulesMap

  class Entities.ResponseCollection extends Entities.Collection
    initialize: (options) ->
      if options.properties? then @set 'properties', new Entities.ResponseProperty options.properties
    model: (attrs, options) ->
      switch attrs.type
        when "text"
          new Entities.TextResponse attrs, options
        else
          new Entities.Response attrs, options


  API =
    init: ($surveyXML) ->
      throw new Error "responses already initialized, use 'responses:destroy' to remove existing responses" unless currentResponses is false
      myResponses = @createResponses App.request("survey:xml:content", $surveyXML)
      currentResponses = new Entities.ResponseCollection myResponses
      console.log 'currentResponses', currentResponses.toJSON()
    getValidationProperties: ($xml, type) ->
      if type in ['single_choice', 'single_choice_custom','multi_choice','multi_choice_custom']
        return false
      $properties = $xml.find("property")
      propObj = {}
      _.each($properties, (child) ->
        $child = $(child)
        propObj[$(child).tagText("key")] = $(child).tagText('label')
      )
      propObj
    createResponses: ($contentXML) ->
      # Loop through all responses.
      # Only want to create a Response for a contentItem that actually
      # can accept responses, so we check its type. Currently a "message"
      # is the only item that does not have a response.
      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.

      _.chain($contentXML.children()).map((child) =>
        $child = $(child)
        myType = $child.tagText('promptType')
        isResponseType = $child.prop('tagName') is 'prompt'
        if isResponseType 
          return {
            id: $child.tagText('id')
            type: myType
            properties: @getValidationProperties($child, myType)
          }
        else
          return false
      ).filter((result) -> !!result).value()
    getResponses: ->
      throw new Error "responses not initialized, use 'responses:init' to create new Responses" unless currentResponses isnt false
      currentResponses


  App.commands.setHandler "responses:init", ($surveyXML) ->
    API.init $surveyXML

  App.reqres.setHandler "responses:current", ->
    API.getResponses()

  App.commands.setHandler "responses:destroy", ->
    currentResponses = false

  App.reqres.setHandler "response:get", (id) ->
    currentResponses = API.getResponses()
    myResponse = currentResponses.get(id)
    throw new Error "response id #{id} does not exist in currentResponses" if typeof myResponse is 'undefined'
    myResponse
