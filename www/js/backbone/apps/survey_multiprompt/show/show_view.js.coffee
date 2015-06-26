@Ohmage.module "SurveyMultipromptApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Progress extends App.Views.ItemView
    template: "survey_multiprompt/show/progress"
    serializeData: ->
      data = @model.toJSON()
      data.percentage = ((data.position / data.duration)*100).toFixed(1)
      data

  class Show.BaseButton extends App.Views.ItemView
    attributes: ->
      if @model.get('disabled') then { class: "disabled" }

  class Show.PrevButton extends Show.BaseButton
    template: "survey_multiprompt/show/prevbutton"
    triggers:
      "click": "prev:clicked"

  class Show.NextButton extends Show.BaseButton
    template: "survey_multiprompt/show/nextbutton"
    triggers:
      "click": "next:clicked"

  class Show.StepError extends App.Views.ItemView
    initialize: ->
      @model.set('customerror', '')

    template: "survey_multiprompt/show/_step_error"

  class Show.StepSkip extends App.Views.ItemView
    template: "survey_multiprompt/show/_step_skip"

  class Show.StepLayout extends App.Views.Layout
    template: "survey_multiprompt/show/_step_layout"
    regions:
      errorRegion: '.inline-error-region'
      skipButtonRegion: '.skip-button-region'
      stepBodyRegion: '.step-body-region'

  class Show.Steps extends App.Views.CollectionView
    childView: Show.StepLayout

  class Show.Layout extends App.Views.Layout
    className: 'survey-step'
    template: "survey_multiprompt/show/show_layout"
    regions:
      noticeRegion: '#notice-region'
      progressRegion: '#progress'
      stepsLayoutRegion: '#step-body'
      prevButtonRegion: '#prev-button'
      nextButtonRegion: '#next-button'
