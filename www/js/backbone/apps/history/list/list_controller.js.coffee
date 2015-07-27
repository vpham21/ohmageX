@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: ->
      @layout = @getLayoutView()
      surveys = App.request 'surveys:saved'

      @listenTo @layout, "show", =>
        if surveys.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','survey')}! You must have saved #{App.dictionary('pages','survey')} in order to view response history for them."
        else
          console.log "showing history layout"

      if surveys.length is 0 
        loadConfig = false
      else
        loadConfig = entities: App.request('history:responses')

      @show @layout, loading: loadConfig

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    getLayoutView: ->
      new List.Layout
