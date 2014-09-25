@Ohmage.module "SurveyStepsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "survey_steps/show/show_layout"
    regions:
      stepBodyRegion: '#step-body'
      skipButtonRegion: '#skip-button'
      prevButtonRegion: '#prev-button'
      nextButtonRegion: '#next-button'