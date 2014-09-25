@Ohmage.module "SurveyStepsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class Show.Controller extends App.Controllers.Application
    initialize: (options) ->
      console.log "SurveyStepsApp Show.Controller"
      { surveyId, stepId } = options
      @surveyId = surveyId
      @stepId = stepId
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @stepBodyRegion()
        @prevButtonRegion()
        @nextButtonRegion()

      @show @layout

    stepBodyRegion: ->
      App.execute "steps:view:insert", @layout.stepBodyRegion, @stepId

    prevButtonRegion: ->

      prevEntity = App.request "stepbutton:prev:entity", @stepId
      prevView = @getPrevButtonView prevEntity


      @show prevView, region: @layout.prevButtonRegion

    nextButtonRegion: ->

      nextEntity = App.request "stepbutton:next:entity", @stepId
      nextView = @getNextButtonView nextEntity
      @show nextView, region: @layout.nextButtonRegion

    getPrevButtonView: (prevStep) ->
      new Show.PrevButton
        model: prevStep

    getNextButtonView: (nextStep) ->
      new Show.NextButton
        model: nextStep

    getLayoutView: ->
      new Show.Layout
