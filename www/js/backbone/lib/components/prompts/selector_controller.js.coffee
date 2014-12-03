@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  # This Prompt Selector returns a specific view, based on the
  # promptType and loads it with the passed in Entity.

  class Prompts.SelectorController extends App.Controllers.Application
    initialize: (options) ->
      { surveyId, stepId, type, entity } = options

      @surveyId = surveyId
      @stepId = stepId

      @myView = @selectView entity, type

      @listenTo @myView, "customchoice:add:success", (myVal) =>
        console.log "customchoice:add:success handler", myVal
        App.execute "prompt:customchoice:add", @surveyId, @stepId, myVal

      @listenTo @myView, "response:submit", (response, surveyId, stepId) ->
        console.log "response:submit"
        App.execute "response:validate", response, surveyId, stepId

      # Ensure this controller is removed during view cleanup.
      @listenTo @myView, "destroy", @destroy

    selectView: (entity, type) ->
      switch (type)
        when "text"
          return new Prompts.Text
            model: entity
        when "number"
          return new Prompts.Number
            model: entity
        when "timestamp"
          return new Prompts.Timestamp
            model: entity
        when "photo"
          return new Prompts.Photo
            model: entity
        when "single_choice"
          return new Prompts.SingleChoice
            model: entity
            collection: entity.get('properties')
        when "single_choice_custom"
          return new Prompts.SingleChoiceCustom
            model: entity
            collection: entity.get('properties')
        when "multi_choice"
          return new Prompts.MultiChoice
            model: entity
            collection: entity.get('properties')
        when "multi_choice_custom"
          return new Prompts.MultiChoiceCustom
            model: entity
            collection: entity.get('properties')
        else
          return new Prompts.Unsupported
            model: App.request('prompt:unsupported:entity', type)

  App.reqres.setHandler "prompts:view", (surveyId, stepId, entity, type) ->
    selector = new Prompts.SelectorController
      surveyId: surveyId
      stepId: stepId
      entity: entity
      type: type

    selector.myView
