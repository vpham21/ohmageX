@Ohmage.module "SurveyStepsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class Show.Controller extends App.Controllers.Application
    initialize: (options) ->
      console.log "SurveyStepsApp Show.Controller"
      { stepId } = options
      @stepId = stepId
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @stepBodyRegion()

      @show @layout

    stepBodyRegion: ->
      App.execute "steps:view:insert", @layout.stepBodyRegion, @stepId

    getPrevButtonView: (prevStep) ->
      new Show.PrevButton
        model: prevStep

    getNextButtonView: (nextStep) ->
      new Show.NextButton
        model: nextStep

    getLayoutView: ->
      new Show.Layout
