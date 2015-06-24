@Ohmage.module "SurveyMultipromptApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # renders multiple prompts on a given page.
  # A fundamental assumption of multiprompt rendering:
  # if a page begins with an intro, beforeSurveySubmit, or afterSurveySubmit step,
  # it is the ONLY step on that page. Any other assumption will break this layout.
  # This assumption is enforced in the flow_pages entity as well.

  class Show.Controller extends App.Controllers.Application
    initialize: (options) ->
      console.log "SurveyMultipromptApp Show.Controller"
      { surveyId, page } = options
      @surveyId = surveyId
      @page = page
      @firstStep = App.request "flow:page:step:first", @page

      @layout = @getLayoutView()

    noticeRegion: ->
      App.execute "notice:region:set", @layout.noticeRegion

    progressRegion: ->
      # progress is based on the index of the current page's first step within the flow.
      progress = App.request 'flow:progress', @firstStep.get('id')
      progressView = @getProgressView progress

      @show progressView, region: @layout.progressRegion

    stepsLayoutRegion: ->

      switch @firstStep.get('type')
        when 'intro'
          # show the intro layout
          # TODO: Make this a special View, instead of just inserting the prompt in this region
          App.execute "steps:view:insert", @layout.stepsLayoutRegion, @surveyId, @firstStep.get('id')
        when 'beforeSurveySubmit'
          # show the beforeSurveySubmit layout
          # TODO: Make this a special View, instead of just inserting the prompt in this region
          App.execute "steps:view:insert", @layout.stepsLayoutRegion, @surveyId, @firstStep.get('id')
        when 'afterSurveySubmit'
          # show the afterSurveySubmit layout
          # TODO: Make this a special View, instead of just inserting the prompt in this region
          App.execute "steps:view:insert", @layout.stepsLayoutRegion, @surveyId, @firstStep.get('id')
        else
          console.log 'show a layout containing all prompts for this page'
          console.log 'set response validation listeners for this page'


    prevButtonRegion: ->

      prevEntity = App.request "stepbutton:prev:entity", @firstStep.get('id')
      prevView = @getPrevButtonView prevEntity

      @listenTo prevView, "prev:clicked", =>
        App.vent.trigger "survey:step:prev:clicked", @surveyId, @page

      @listenTo App.vent, 'external:survey:prev:navigate', =>
        # Add external hook for navigating backwards in a survey
        App.vent.trigger "survey:step:prev:clicked", @surveyId, @page

      @show prevView, region: @layout.prevButtonRegion

    nextButtonRegion: ->

      nextEntity = App.request "stepbutton:next:entity", @firstStep.get('id')
      nextView = @getNextButtonView nextEntity

      @listenTo nextView, "next:clicked", =>
        console.log 'nextview listento next:clicked'

        switch @firstStep.get('type')
          when "intro"
            App.vent.trigger "survey:intro:next:clicked", @surveyId, @page
          when "beforeSurveySubmit"
            App.vent.trigger "survey:beforesubmit:next:clicked", @surveyId, @page
          when "afterSurveySubmit"
            App.vent.trigger "survey:aftersubmit:next:clicked", @surveyId, @page
          else
            App.vent.trigger "survey:page:responses:get", @surveyId, @page

      @show nextView, region: @layout.nextButtonRegion

    getProgressView: (progress) ->
      new Show.Progress
        model: progress

    getPrevButtonView: (prevStep) ->
      new Show.PrevButton
        model: prevStep

    getNextButtonView: (nextStep) ->
      new Show.NextButton
        model: nextStep

    getLayoutView: ->
      new Show.Layout
