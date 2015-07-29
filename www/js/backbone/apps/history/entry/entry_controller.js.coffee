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
        @detailsRegion entry
        @noticeRegion()

      @show @layout, loading: false

    noticeRegion: ->
      App.execute "notice:region:set", @layout.noticeRegion

    detailsRegion: (entry) ->
      detailsView = @getDetailsView entry

      @listenTo detailsView, "close:clicked", (args) =>
        console.log 'childview:close:clicked', entry
        App.vent.trigger "history:entry:close:clicked", entry

      @show detailsView, region: @layout.detailsRegion


    getLayoutView: (entry) ->
      new Entry.Layout
        model: entry
