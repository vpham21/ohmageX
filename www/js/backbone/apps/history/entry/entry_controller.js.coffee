@Ohmage.module "HistoryApp.Entry", (Entry, App, Backbone, Marionette, $, _) ->

  # History Entry Controller renders a single entry in the history.

  class Entry.Controller extends App.Controllers.Application
    initialize: (options) ->
      { entry_id } = options
      @entry_id = entry_id

      @listenTo App.vent, 'history:entry:remove:success', (entry) =>
        if entry.get('id') is @entry_id then App.historyBack()

      entry = App.request "history:entry", @entry_id

      @layout = @getLayoutView entry

      @listenTo @layout, "show", =>
        console.log "show entry layout"
        @detailsRegion entry
        responses = App.request "history:entry:responses", @entry_id
        @responsesRegion responses
        @noticeRegion()

      @show @layout, loading: false

    noticeRegion: ->
      App.execute "notice:region:set", @layout.noticeRegion

    detailsRegion: (entry) ->
      detailsView = @getDetailsView entry

      @listenTo detailsView, "delete:clicked", (args) =>
        console.log 'childview:delete:clicked', entry
        App.vent.trigger "history:entry:delete:clicked", entry

      @listenTo detailsView, "close:clicked", (args) =>
        console.log 'childview:close:clicked', entry
        App.vent.trigger "history:entry:close:clicked", entry

      @show detailsView, region: @layout.detailsRegion

    responsesRegion: (responses) ->
      responsesView = @getResponsesView responses

      @show responsesView, region: @layout.responsesRegion

    getResponsesView: (responses) ->
      new Entry.Responses
        collection: responses

    getDetailsView: (entry) ->
      new Entry.Details
        model: entry

    getLayoutView: (entry) ->
      new Entry.Layout
        model: entry
