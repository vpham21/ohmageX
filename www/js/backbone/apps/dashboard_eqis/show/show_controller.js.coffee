@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # DashboardeQISApp renders the e-QIS dashboard.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      campaigns = App.request "campaigns:saved:current"

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! You must have saved #{App.dictionary('pages','campaign')} in order to view your dashboard."
        else
          console.log "showing layout"
          artifacts = App.request "dashboardeqis:artifacts"
          @artifactsRegion artifacts

      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion


    artifactsRegion: (artifacts) ->
      artifactsView = @getArtifactsView artifacts

      @listenTo artifactsView, "childview:newsurvey:first:clicked", (child, args) ->
        console.log "childview:newsurvey:first:clicked", args.model
        App.vent.trigger "dashboardeqis:newsurvey:clicked", args.model.get 'surveyId', args.model.get 'newPrepopIndex'

      @listenTo artifactsView, "childview:newsurvey:second:clicked", (child, args) ->
        console.log "childview:newsurvey:second:clicked", args.model
        App.vent.trigger "dashboardeqis:newsurvey:clicked", args.model.get 'secondSurveyId', args.model.get 'newPrepopIndex'


      @show artifactsView, region: @layout.artifactsRegion

    getNoticeView: (notice) ->
      new Show.Notice
        model: notice

    getArtifactsView: (artifacts) ->
      new Show.Artifacts
        collection: artifacts

    getLayoutView: ->
      new Show.Layout
