@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  # This Prompt Selector returns a specific view, based on the
  # promptType and loads it with the passed in Entity.

  class Prompts.SelectorController extends App.Controllers.Application
    initialize: (options) ->
      { entity, type } = options

      @myView = @selectView entity, type

      @listenTo @myView, "response:submit", (response, surveyId, stepId) ->
        console.log "response:submit"
        App.execute "response:validate", response, surveyId, stepId

      # Ensure this controller is removed during view cleanup.
      @listenTo @myView, "close", @close

    selectView: (entity, type) ->
      switch (type)
        when "text"
          return new Prompts.Text
            model: entity
        when "number"
          return new Prompts.Number
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

  App.reqres.setHandler "prompts:view", (entity, type) ->
    selector = new Prompts.SelectorController
      entity: entity
      type: type

    selector.myView
