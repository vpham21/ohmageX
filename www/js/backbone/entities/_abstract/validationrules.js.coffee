@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # This contains all of the Rules for the given field's
  # validation. We use a basic Object instead of a BB
  # model to keep the definition simple. This object is intended
  # to be created privately within the `validate` method of an
  # Entity that uses it, so it does not need an event interface.

  # it uses the Decorator pattern to add Rules and execute all
  # added rules as needed on the passed-in properties.

  class Entities.ValidatedModel extends Entities.Model
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

      # pass along attributes to an internal success
      # event that the child model can listen for and
      # use to propagate updates up the event chain.
      @trigger "internal:success", attrs

      # this does not return if there are no errors,
      # because the BB Model validate method
      # only succeeds when nothing is returned
      return

  class Entities.ValidationRules
    constructor: (options) ->
      # this expects the options object to contain:
      # value - the response value
      # rulesMap - the properties in [{ruleName: compareValue}] format
      @errors = []
      # extracts a list of rules to execute from the rulesMap.
      console.log 'options.rulesMap', options.rulesMap
      @rulesList = _.map(options.rulesMap, (compareValue, ruleName) -> 
        ruleName
      )
      if 'minValue' in @rulesList and 'maxValue' in @rulesList
        @replaceWithRangeRule options
      @validate options

    replaceWithRangeRule: (options) ->
      options.rulesMap.range =
        minValue: options.rulesMap.minValue
        maxValue: options.rulesMap.maxValue
      @rulesList = _.filter(@rulesList, (name) -> name isnt 'minValue' and name isnt 'maxValue')
      @rulesList.push('range')
    rules:
      # Rules expect that the comparison value they're using
      # has the same name as the rule.
      minLength:
        validate: (options) ->
          {value, rulesMap} = options
          if value.length < parseInt(rulesMap.minLength)
            @errors.push "Value too short, length must be at least #{rulesMap.minLength}."
      maxLength:
        validate: (options) ->
          {value, rulesMap} = options
          if value.length > parseInt(rulesMap.maxLength)
            @errors.push "Value too long, length must be less than #{rulesMap.maxLength}."
      minValue:
        validate: (options) ->
          {value, rulesMap} = options
          valueNum = parseInt(value)
          minValue = parseInt(rulesMap.minValue)
          if valueNum < minValue
            @errors.push "Value too low, must be greater than #{minValue}."
      maxValue:
        validate: (options) ->
          {value, rulesMap} = options
          valueNum = parseInt(value)
          maxValue = parseInt(rulesMap.maxValue)
          if valueNum > maxValue
            @errors.push "Value too high, must be less than #{maxValue}."
      range:
        validate: (options) ->
          {value, rulesMap} = options
          valueNum = parseInt(value)
          minValue = parseInt(rulesMap.range.minValue)
          maxValue = parseInt(rulesMap.range.maxValue)
          if valueNum < minValue
            @errors.push "Value too low, must be between #{minValue} and #{maxValue}."
          if valueNum > maxValue
            @errors.push "Value too high, must be between #{minValue} and #{maxValue}."
      wholeNumber:
        validate: (options) ->
          {value, rulesMap} = options
          if rulesMap.wholeNumber is "false"
            # allow decimal numbers only.
            validChars = /^(?!\.?$)\d{0,99}(\.\d{0,9})?$/i
            if !validChars.test(value)
              @errors = ["Not a valid decimal number."]
          else
            # allow whole numbers only.
            validChars = /^\-?[0-9]+$/i
            if !validChars.test(value)
              @errors = ["Not a valid whole number."]
      timestampISO:
        validate: (options) ->
          # we're testing that the value can be turned into
          # a Date object, and then converted successfully
          # into an ISO string without an issue.

          # rulesMap is not used in this rule, there's
          # no custom property XML.
          {value} = options

          try
            m = moment(value)
            if !m.isValid() then @errors = ["Invalid timestamp."]
          catch
            @errors = ['Invalid timestamp.']
      futureTimestamp:
        validate: (options) ->
          # we're testing that the value is a Date object in the future.

          # rulesMap is not used in this rule, there's
          # no custom property XML.
          {value} = options
          try
            now = moment()
            if now.diff(value) > 0 then @errors = ["Timestamp needs to be in the future."]
          catch
            @errors = ['Timestamp needs to be in the future.']
      maxSize:
        validate: (options) ->
          console.log 'maxSize validator'
          {value, rulesMap} = options
          if rulesMap.maxSize isnt false
            # if a maxFileSize isnt set, skip validation
            # value is the custom response file object
            sizeNum = parseInt(value.fileSize)
            maxSize = parseInt(rulesMap.maxSize)
            if sizeNum > maxSize
              @errors.push "File is too large at #{value.fileSize} bytes, must be less than #{maxSize} bytes."
      httpHost:
        validate: (options) ->
          # rulesMap is not used here, no custom property XML.
          {value} = options
          console.log 'value', value
          validHttp = /^http(s)?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,20}(:[0-9]{1,5})?(\/.*)?$/i
          if !validHttp.test(value)
            @errors = ["Invalid Server path."]

    validate: (options) ->
      console.log 'rulesList', @rulesList
      _.each(@rulesList, (ruleName) =>
        @rules[ruleName].validate.call(@, options)
      )
      @errors
