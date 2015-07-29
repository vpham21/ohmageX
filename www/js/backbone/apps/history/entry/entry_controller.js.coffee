@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->

  # History Entry Controller renders a single entry in the history.

  class Entry.Controller extends App.Controllers.Application
    initialize: (options) ->
      { entry_id } = options
      @entry_id = entry_id
      entry = App.request "history:entry", @entry_id

      @layout = @getLayoutView entry

      @listenTo @layout, "show", =>
        console.log "show entry layout"
        @noticeRegion()

      @show @layout, loading: false

    noticeRegion: ->
      App.execute "notice:region:set", @layout.noticeRegion


    getLayoutView: (entry) ->
      new Entry.Layout
        model: entry
