@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: (options) ->

      @layout = @getLayoutView()
      campaigns = App.request "campaigns:saved:current"
      if campaigns.length isnt 0
        entries = App.request('history:entries:filtered', App.request("history:entries"))
        bucketsSelector = App.request "history:selector:buckets", App.request("history:entries")
        @buckets_filter = options.buckets_filter

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! You must have saved #{App.dictionary('pages','campaign')} in order to view response history for them."
        else
          console.log "showing history layout"
          @bucketRegion bucketSelector
          @listRegion entries

      if campaigns.length is 0
        loadConfig = false
      else
        loadConfig = entities: entries

      @show @layout, loading: loadConfig

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    bucketRegion: (buckets) ->
      bucketView = @getBucketsView buckets

      @show bucketView, region: @layout.bucketsControlRegion

    listRegion: (responses) ->
      listView = @getListView responses

      @listenTo listView, "childview:clicked", (args) =>
        console.log 'childview:entry:clicked', args.model
        App.vent.trigger "history:list:entry:clicked", args.model

      @show listView, region: @layout.listRegion

    getLayoutView: ->
      new List.Layout

    getNoticeView: (notice) ->
      new List.Notice
        model: notice

    getBucketsView: (buckets) ->
      new List.BucketsSelector
        collection: buckets

    getListView: (entries) ->
      new List.Entries
        collection: entries
