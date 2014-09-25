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

      @listenTo prevView, "prev:clicked", =>
        App.vent.trigger "survey:step:prev:clicked", @stepId

      @show prevView, region: @layout.prevButtonRegion

    nextButtonRegion: ->

      nextEntity = App.request "stepbutton:next:entity", @stepId
      nextView = @getNextButtonView nextEntity

      @listenTo nextView, "next:clicked", =>
        myType = App.request "flow:type", @stepId
        console.log 'nextview listento next:clicked'
        switch myType
          when "intro"
            App.vent.trigger "survey:intro:next:clicked", @surveyId, @stepId
          when "message"
            App.vent.trigger "survey:message:next:clicked", @surveyId, @stepId
          when "beforeSurveySubmit"
            App.vent.trigger "survey:beforesubmit:next:clicked", @surveyId, @stepId
          when "afterSurveySubmit"
            App.vent.trigger "survey:aftersubmit:next:clicked", @surveyId, @stepId
          else
            App.vent.trigger "survey:response:get", @surveyId, @stepId

      @show nextView, region: @layout.nextButtonRegion

    getPrevButtonView: (prevStep) ->
      new Show.PrevButton
        model: prevStep

    getNextButtonView: (nextStep) ->
      new Show.NextButton
        model: nextStep

    getLayoutView: ->
      new Show.Layout
