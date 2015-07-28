@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()
      campaigns = App.request "campaigns:saved:current"

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! You must have saved #{App.dictionary('pages','campaign')} in order to view response history for them."
        else
          console.log "showing history layout"

      if campaigns.length is 0
        loadConfig = false
      else
        loadConfig = entities: App.request('history:entries')

      @show @layout, loading: loadConfig

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    getLayoutView: ->
      new List.Layout

    getNoticeView: (notice)->
      new List.Notice
        model: notice

