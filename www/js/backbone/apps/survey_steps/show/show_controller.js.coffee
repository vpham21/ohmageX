@Ohmage.module "SurveyStepsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class Show.Controller extends App.Controllers.Application
    initialize: (options) ->
      { stepId } = options
      myType = App.request "flow:type", stepId
      myEntity = App.request "flow:entity", stepId
      console.log "myEntity for #{stepId}",myEntity.toJSON()