@Ohmage.module "SurveysApp.List", (List, App, Backbone, Marionette, $, _) ->

  # Surveys List currently renders a list of ALL available surveys
  # for a user, retrieved from the server.

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
