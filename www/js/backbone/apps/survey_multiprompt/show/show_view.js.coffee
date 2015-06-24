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


  class Show.Layout extends App.Views.Layout
    className: 'survey-step'
    template: "survey_multiprompt/show/show_layout"
    regions:
      noticeRegion: '#notice-region'
      progressRegion: '#progress'
      stepsLayoutRegion: '#step-body'
      prevButtonRegion: '#prev-button'
      nextButtonRegion: '#next-button'
