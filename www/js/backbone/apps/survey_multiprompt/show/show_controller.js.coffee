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

