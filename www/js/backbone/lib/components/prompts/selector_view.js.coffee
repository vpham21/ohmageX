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
    template: "prompts/prompt"
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
