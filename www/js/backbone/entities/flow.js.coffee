@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.

  # "flow:init" initializes a StepCollection that persists in memory.
  # That collection is removed with "flow:destroy"

  class Entities.Step extends Entities.Model

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