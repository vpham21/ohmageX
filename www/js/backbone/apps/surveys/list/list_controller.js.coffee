@Ohmage.module "DashboardApp.List", (List, App, Backbone, Marionette, $, _) ->

  # Dashboard currently renders a series of prompts in sequence on a single page,
  # showing that the XML is being parsed and rendering templates as a result.
  # These are added to a Layout containing multiple individual regions
  # with each region assigned an individual Prompt.

  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      surveys = App.request "campaign:surveys", options.campaign_id
      @layout = @getLayoutView surveys

      @listenTo @layout, "show", =>
        console.log "show list layout"
        @surveysRegion surveys
        @logoutRegion()

      @show @layout, loading: true

    surveysRegion: (surveys) ->
      surveysView = @getSurveysView surveys

      @listenTo surveysView, "childview:survey:clicked", (child, args) ->
        console.log 'childview:survey:clicked args', args.model
        App.vent.trigger "survey:list:item:clicked", args.model

      @show surveysView, region: @layout.listRegion

    logoutRegion: ->
      logoutView = @getLogoutView()

      @listenTo logoutView, "logout:clicked", ->
        console.log 'logout clicked'
        App.vent.trigger "survey:list:logout:clicked"

      @show logoutView, region: @layout.logoutRegion

    getLogoutView: ->
      new List.Logout

    getSurveysView: (surveys) ->
      new List.Surveys
        collection: surveys

    getLayoutView: (surveys) ->
      new List.Layout
        collection: surveys
