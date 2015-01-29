@Ohmage.module "Components.Steps", (Steps, App, Backbone, Marionette, $, _) ->

  # This Step Selector instantiates a view to insert into the passed-in
  # region, based on retrieving a step via ID from currentFlow.
  # It references the currentFlow using the handlers 
  # "flow:type" and "flow:entity"

  class Steps.SelectorController extends App.Controllers.Application

    initialize: (options) ->
      { surveyId, stepId, type, entity } = options

      @surveyId = surveyId
      @stepId = stepId

      myView = @selectView entity, type

      if type is "afterSurveySubmit"
        @listenTo myView, 'new:reminder', =>
          App.vent.trigger "reminders:survey:new", @surveyId

      @showSelectedView myView

    selectView: (entity, type) ->
      switch (type)
        when "intro"
          return new Steps.Intro
            model: entity
        when "message"
          return new Steps.Message
            model: entity
        when "beforeSurveySubmit"
          return new Steps.BeforeSubmission
            model: entity          
        when "afterSurveySubmit"
          return new Steps.AfterSubmission
            model: entity
        else
          # handle all other view types in the Prompts component.
          return App.request "prompts:view", @surveyId, @stepId, entity, type

    showSelectedView: (view) ->
      @show view

  App.commands.setHandler "steps:view:insert", (region, surveyId, stepId) ->
    result = new Steps.SelectorController
      region: region
      surveyId: surveyId
      stepId: stepId
      type: App.request "flow:type", stepId
      entity: App.request "flow:entity", stepId
