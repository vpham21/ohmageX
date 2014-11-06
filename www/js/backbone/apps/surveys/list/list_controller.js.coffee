@Ohmage.module "SurveysApp.List", (List, App, Backbone, Marionette, $, _) ->

  # Surveys List currently renders a list of ALL available surveys
  # for a user, retrieved from the server.

  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      if options.campaign_id
        surveys = App.request "surveys:saved:campaign", options.campaign_id
      else
        surveys = App.request "surveys:saved"
      @layout = @getLayoutView surveys

      @listenTo @layout, "show", =>
        console.log "show list layout"
        @surveysRegion surveys
        @logoutRegion()

      @show @layout, loading: false

    surveysRegion: (surveys) ->
      surveysView = @getSurveysView surveys

      @listenTo surveysView, "childview:running:clicked", (child, args) ->
        console.log 'childview:running:clicked args', args.model
        App.vent.trigger "survey:list:running:clicked", args.model

      @listenTo surveysView, "childview:stopped:clicked", (child, args) ->
        console.log 'childview:stopped:clicked args', args.model
        App.vent.trigger "survey:list:stopped:clicked", args.model

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
