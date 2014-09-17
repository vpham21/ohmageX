@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.

  # currentFlow
  # "flow:init" initializes a StepCollection that persists in memory.
  # This collection is removed with "flow:destroy"
  currentFlow = false

  # Possible status list:
  # pending        - Not yet navigated to, and its Condition is not yet tested
  # displaying     - currently rendered, no response from the user yet
  # not_displayed  - not displayed because its condition evaluated to false
  # complete       - has been displayed, and the user has submitted a valid value
  # skipped        - the user intentionally skipped this Step

  class Entities.Step extends Entities.Model
    defaults: # default values for all Steps:
      condition: true # Step is always shown
      entity: false # entity is not initialized
      skippable: false # Step can't be skipped
      skiplabel: false # Skip label is empty
      status: "pending" # Step hasn't been processed

  class Entities.StepCollection extends Entities.Collection
    model: Entities.Step

  API =
    init: ($surveyXML) ->
      throw new Error "flow already initialized, use 'flow:destroy' to remove existing flow" unless currentFlow is false
      currentFlow = new Entities.StepCollection
      myIntroStep = @createIntroStep App.request("survey:xml:root", $surveyXML)
      currentFlow.add myIntroStep
      myContentSteps = @createContentSteps App.request("survey:xml:content", $surveyXML)
      currentFlow.add myContentSteps
      mySurveySubmitSteps = @createSurveySubmitSteps App.request("survey:xml:root", $surveyXML)
      currentFlow.add mySurveySubmitSteps
      console.log 'Current flow Object', currentFlow.toJSON()

    createIntroStep: ($rootXML) ->

      # no showSummary tag? assume we show this Step.
      introCondition = !!!$rootXML.find('showSummary') or $rootXML.tagText('showSummary') is "true"

      result =
        id: "#{$rootXML.tagText('id')}Intro"
        type: "intro"
        condition: introCondition
        status: if introCondition then "displayed" else "not_displayed"

    createContentSteps: ($contentXML) ->
      _.map( $contentXML.children(), (child) ->
        $child = $(child)

        isMessage = $child.prop('tagName') is 'message'
        conditionExists = !!$child.find('condition').length

        result =
          id: $child.tagText('id')
          type: if isMessage then "message" else $child.tagText('promptType')
          condition: if conditionExists then $child.tagText('condition') else true
      )

    createSurveySubmitSteps: ($rootXML) ->
      result = []
      result.push
        id: "#{$rootXML.tagText('id')}beforeSurveySubmit"
        type: "beforeSurveySubmit"

      result.push
        id: "#{$rootXML.tagText('id')}afterSurveySubmit"
        type: "afterSurveySubmit"

      result

  App.commands.setHandler "flow:init", ($surveyXML) ->
    API.init $surveyXML
