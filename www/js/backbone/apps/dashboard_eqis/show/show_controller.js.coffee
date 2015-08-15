@Ohmage.module "DashboardeQISApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  # DashboardeQISApp renders the e-QIS dashboard.

  class Show.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()

      campaigns = App.request "campaigns:saved:current"

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! Download #{App.dictionary('pages','campaign')} from the #{App.dictionary('pages','campaign').capitalizeFirstLetter()} Menu section to view your #{App.dictionary('page','dashboardeqis')}."
        else
          console.log "showing layout"
          artifacts = App.request "dashboardeqis:artifacts"
          @artifactsRegion artifacts

      @show @layout

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion


    campaignRegion: (campaign) ->
      campaignView = @getCampaignView campaign

      @show campaignView, region: @layout.campaignRegion

    artifactsRegion: (artifacts, campaign) ->
      artifactsView = @getArtifactsView artifacts

      @listenTo artifactsView, "childview:newsurvey:first:clicked", (child, args) ->
        console.log "childview:newsurvey:first:clicked", args.model
        App.vent.trigger "dashboardeqis:newsurvey:clicked", args.model.get('surveyId'), args.model.get('newPrepopIndex'), args.model.get('newPrepopfirstSurveyStep')

      @listenTo artifactsView, "childview:newsurvey:second:clicked", (child, args) ->
        console.log "childview:newsurvey:second:clicked", args.model
        App.vent.trigger "dashboardeqis:newsurvey:clicked", args.model.get('secondSurveyId'), args.model.get('newPrepopIndex'), args.model.get('newPrepopSecondSurveyStep')

      @listenTo artifactsView, "childview:responsecount:clicked", (child, args) ->
        console.log "childview:responsecount:clicked", args.model
        if args.model.get('responseCount') is 0
          App.execute "dialog:alert", "There are no responses to show for this category."
        else
          App.vent.trigger "dashboardeqis:responsecount:clicked", args.model.get 'bucket'

      @show artifactsView, region: @layout.artifactsRegion

    getNoticeView: (notice) ->
      new Show.Notice
        model: notice

    getCampaignView: (campaign) ->
      new Show.Campaign
        model: campaign


    getArtifactsView: (artifacts) ->
      new Show.Artifacts
        collection: artifacts

    getLayoutView: ->
      new Show.Layout
