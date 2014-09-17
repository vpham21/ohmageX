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

  currentFlow = false

  API =
    init: ($surveyXML) ->
      throw new Error "flow already initialized, use 'flow:destroy' to remove existing flow" unless currentFlow is false
      @createIntroStep App.request("survey:xml:root", $surveyXML)
    createIntroStep: ($stepXML) ->

      # no showSummary tag? assume we show it.
      myCondition = !!!$stepXML.find('showSummary') or $stepXML.tagText('showSummary') is "true"

      result = 
        id: "#{$stepXML.tagText('id')}Intro"
        type: "intro"
        condition: myCondition
        skippable: false # intro step can never be skipped, no input is required
        status: if myCondition then "displayed" else "not_displayed"

      console.log result

  App.commands.setHandler "flow:init", ($surveyXML) ->
    API.init $surveyXML
