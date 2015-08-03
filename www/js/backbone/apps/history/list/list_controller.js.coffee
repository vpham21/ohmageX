@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()
      campaigns = App.request "campaigns:saved:current"

      if campaigns.length isnt 0
        entries = App.request('history:entries:filtered', App.request("history:entries"))
        bucketSelector = App.request "history:selector:buckets", App.request("history:entries")

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! You must have saved #{App.dictionary('pages','campaign')} in order to view response history for them."
        else
          console.log "showing history layout"
          @listRegion entries

      if campaigns.length isnt 0
        @listenTo entries, "filter:bucket:clear", =>
          # pass the filter clearing in entries
          # to the selector entity, so its view can update
          bucketSelector.trigger "filter:bucket:clear"

        @listenTo bucketSelector, "change:chosen", (model) =>
          # this event fires every time all instances of the
          # `chosen` attribute within the model are changed.
          # So only activate when our model is "chosen"
          if model.isChosen()
            if model.get('name') is 'All'
              entries.where()
            else
              entries.where(bucket: model.get('name'))

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
