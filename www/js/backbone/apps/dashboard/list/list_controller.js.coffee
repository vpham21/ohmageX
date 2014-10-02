@Ohmage.module "DashboardApp.List", (List, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class List.Controller extends App.Controllers.Application

    initialize: ->
      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        console.log "show list layout"
        @surveysRegion()

      @show @layout

    surveysRegion: ->
      surveys = App.request "campaign:surveys"
      surveysView = @getSurveysView surveys

      @listenTo surveysView, "childview:survey:clicked", (child, args) ->
        console.log 'childview:survey:clicked args'

      @show surveysView, region: @layout.surveysRegion

    getSurveysView: (surveys) ->
      new List.Surveys
        collection: surveys

    getLayoutView: ->
      new List.Layout
