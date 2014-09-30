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
      $valueField.val( parseInt($valueField.val())+1 )
    decrementValue: ->
      $valueField = @$el.find("input[type='text']")
      $valueField.val( parseInt($valueField.val())-1 )
    triggers:
      "click button.increment": "value:increment"
      "click button.decrement": "value:decrement"

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

  class Prompts.MultiChoiceItem extends App.Views.ItemView
    tagName: 'li'
    template: "prompts/multi_choice_item"

  # Prompt Multi Choice
  class Prompts.MultiChoice extends Prompts.SingleChoice
    template: "prompts/multi_choice"
    itemView: Prompts.MultiChoiceItem
    itemViewContainer: ".prompt-list"
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